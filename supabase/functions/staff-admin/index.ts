import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const ALLOWED_ORIGINS = [
  "https://www.routineready.co.uk",
  "https://routineready.co.uk",
];

function getCorsHeaders(req: Request) {
  const origin = req.headers.get("Origin") ?? "";
  const allowedOrigin = ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0];
  return {
    "Access-Control-Allow-Origin": allowedOrigin,
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  };
}

const STAFF_DOMAINS = ["@routineready.app", "@routineready.co.uk"];

function isStaffEmail(email: string | undefined): boolean {
  if (!email) return false;
  return STAFF_DOMAINS.some((domain) => email.endsWith(domain));
}

const INVITE_REDIRECT_TO = "https://www.routineready.co.uk/app/";

function jsonResponse(data: unknown, status = 200, corsHeaders: Record<string, string> = {}) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

// --- Input validation helpers ---

function validateRequired(params: Record<string, unknown>, fields: string[]): string | null {
  for (const field of fields) {
    if (params[field] === undefined || params[field] === null || params[field] === "") {
      return `Missing required field: ${field}`;
    }
  }
  return null;
}

function validateEmail(email: string): string | null {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return `Invalid email format: ${email}`;
  }
  return null;
}

function validateStringLength(value: string, field: string, min: number, max: number): string | null {
  if (value.length < min) return `${field} must be at least ${min} characters`;
  if (value.length > max) return `${field} must be at most ${max} characters`;
  return null;
}

Deno.serve(async (req: Request) => {
  const cors = getCorsHeaders(req);

  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: cors });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    // Extract JWT from Authorization header
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ error: "Missing authorization header" }, 401, cors);
    }

    const token = authHeader.replace(/^Bearer\s+/i, "");

    // Use service role client to verify the user from the token
    const admin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    const { data: { user }, error: userError } = await admin.auth.getUser(token);

    if (userError || !user) {
      return jsonResponse({ error: "Invalid token", detail: userError?.message ?? "No user found" }, 401, cors);
    }

    if (!isStaffEmail(user.email)) {
      return jsonResponse({ error: "Forbidden", email: user.email }, 403, cors);
    }

    const { action, ...params } = await req.json();

    let result: unknown;

    switch (action) {
      case "list_organizations": {
        const { data: orgs, error } = await admin
          .from("organizations")
          .select("*")
          .order("name");
        if (error) throw error;

        const enriched = await Promise.all(
          (orgs ?? []).map(async (org: { id: string; name: string; created_at: string }) => {
            const { count: memberCount } = await admin
              .from("org_members")
              .select("*", { count: "exact", head: true })
              .eq("org_id", org.id);
            const { count: schoolCount } = await admin
              .from("schools")
              .select("*", { count: "exact", head: true })
              .eq("org_id", org.id);
            return { ...org, member_count: memberCount ?? 0, school_count: schoolCount ?? 0 };
          })
        );
        result = enriched;
        break;
      }

      case "get_organization": {
        const { org_id } = params;
        const reqErr = validateRequired(params, ["org_id"]);
        if (reqErr) return jsonResponse({ error: reqErr }, 400, cors);

        const { data: org, error } = await admin
          .from("organizations")
          .select("*")
          .eq("id", org_id)
          .single();
        if (error) throw error;

        const { data: members } = await admin
          .from("org_members")
          .select("*")
          .eq("org_id", org_id);

        const enrichedMembers = await Promise.all(
          (members ?? []).map(async (m: { user_id: string; [key: string]: unknown }) => {
            const { data: { user: authUser } } = await admin.auth.admin.getUserById(m.user_id);
            return { ...m, email: authUser?.email ?? "unknown" };
          })
        );

        const { data: schools } = await admin
          .from("schools")
          .select("*")
          .eq("org_id", org_id)
          .order("class_name");

        result = { ...org, members: enrichedMembers, schools: schools ?? [] };
        break;
      }

      case "create_organization": {
        const { name } = params;
        const reqErr = validateRequired(params, ["name"]);
        if (reqErr) return jsonResponse({ error: reqErr }, 400, cors);
        const lenErr = validateStringLength(name, "Organization name", 1, 200);
        if (lenErr) return jsonResponse({ error: lenErr }, 400, cors);

        const { data, error } = await admin
          .from("organizations")
          .insert({ name })
          .select()
          .single();
        if (error) throw error;
        result = data;
        break;
      }

      case "update_organization": {
        const { org_id, name } = params;
        const reqErr = validateRequired(params, ["org_id", "name"]);
        if (reqErr) return jsonResponse({ error: reqErr }, 400, cors);
        const lenErr = validateStringLength(name, "Organization name", 1, 200);
        if (lenErr) return jsonResponse({ error: lenErr }, 400, cors);

        const { data, error } = await admin
          .from("organizations")
          .update({ name })
          .eq("id", org_id)
          .select()
          .single();
        if (error) throw error;
        result = data;
        break;
      }

      case "delete_organization": {
        const { org_id } = params;
        const reqErr = validateRequired(params, ["org_id"]);
        if (reqErr) return jsonResponse({ error: reqErr }, 400, cors);

        // DB cascades handle org_members, schools, and all school children
        const { error } = await admin.from("organizations").delete().eq("id", org_id);
        if (error) throw error;
        result = { success: true };
        break;
      }

      case "create_school": {
        const { org_id, owner_id, school_name, class_name, teacher_name, device_name } = params;
        const reqErr = validateRequired(params, ["org_id"]);
        if (reqErr) return jsonResponse({ error: reqErr }, 400, cors);

        const { data, error } = await admin
          .from("schools")
          .insert({
            org_id,
            owner_id: owner_id ?? user.id,
            school_name: school_name ?? "",
            class_name: class_name ?? "",
            teacher_name: teacher_name ?? "",
            device_name: device_name ?? "Display 1",
          })
          .select()
          .single();
        if (error) throw error;
        result = data;
        break;
      }

      case "update_school": {
        const { school_id, ...fields } = params;
        const reqErr = validateRequired(params, ["school_id"]);
        if (reqErr) return jsonResponse({ error: reqErr }, 400, cors);

        const updateFields: Record<string, unknown> = {};
        for (const key of ["school_name", "class_name", "teacher_name", "device_name", "owner_id", "is_active"]) {
          if (fields[key] !== undefined) updateFields[key] = fields[key];
        }
        const { data, error } = await admin
          .from("schools")
          .update(updateFields)
          .eq("id", school_id)
          .select()
          .single();
        if (error) throw error;
        result = data;
        break;
      }

      case "delete_school": {
        const { school_id } = params;
        const reqErr = validateRequired(params, ["school_id"]);
        if (reqErr) return jsonResponse({ error: reqErr }, 400, cors);

        // DB cascades handle all child tables
        const { error } = await admin.from("schools").delete().eq("id", school_id);
        if (error) throw error;
        result = { success: true };
        break;
      }

      case "list_users": {
        const { data: { users: authUsers }, error } = await admin.auth.admin.listUsers();
        if (error) throw error;

        const enriched = await Promise.all(
          (authUsers ?? []).map(async (u: { id: string; email?: string; created_at: string }) => {
            const { data: memberships } = await admin
              .from("org_members")
              .select("id, org_id, role, organizations(name)")
              .eq("user_id", u.id);
            return {
              id: u.id,
              email: u.email ?? "",
              created_at: u.created_at,
              memberships: memberships ?? [],
            };
          })
        );
        result = enriched;
        break;
      }

      case "create_user": {
        const { email, password, org_id, role } = params;
        const reqErr = validateRequired(params, ["email", "password"]);
        if (reqErr) return jsonResponse({ error: reqErr }, 400, cors);
        const emailErr = validateEmail(email);
        if (emailErr) return jsonResponse({ error: emailErr }, 400, cors);
        const pwErr = validateStringLength(password, "Password", 8, 128);
        if (pwErr) return jsonResponse({ error: pwErr }, 400, cors);

        const { data: newUser, error } = await admin.auth.admin.createUser({
          email,
          password,
          email_confirm: true,
        });
        if (error) throw error;

        if (org_id && newUser.user) {
          const { error: memberError } = await admin.from("org_members").insert({
            org_id,
            user_id: newUser.user.id,
            role: role ?? "teacher",
          });
          if (memberError) throw memberError;
        }

        result = { id: newUser.user?.id, email: newUser.user?.email };
        break;
      }

      case "invite_user": {
        const { email, org_id, role } = params;
        const reqErr = validateRequired(params, ["email"]);
        if (reqErr) return jsonResponse({ error: reqErr }, 400, cors);
        const emailErr = validateEmail(email);
        if (emailErr) return jsonResponse({ error: emailErr }, 400, cors);

        // Sends the Supabase "Invite user" email; the invitee sets their own
        // password via the in-app set-password screen.
        const { data: invited, error } = await admin.auth.admin.inviteUserByEmail(email, {
          redirectTo: INVITE_REDIRECT_TO,
        });
        if (error) throw error;

        if (org_id && invited.user) {
          const { error: memberError } = await admin.from("org_members").insert({
            org_id,
            user_id: invited.user.id,
            role: role ?? "teacher",
          });
          if (memberError) throw memberError;
        }

        result = { id: invited.user?.id, email: invited.user?.email };
        break;
      }

      case "delete_user": {
        const { user_id } = params;
        const reqErr = validateRequired(params, ["user_id"]);
        if (reqErr) return jsonResponse({ error: reqErr }, 400, cors);

        // DB cascades handle org_members cleanup when auth user is deleted
        const { error } = await admin.auth.admin.deleteUser(user_id);
        if (error) throw error;
        result = { success: true };
        break;
      }

      case "reset_user_password": {
        const { email } = params;
        const reqErr = validateRequired(params, ["email"]);
        if (reqErr) return jsonResponse({ error: reqErr }, 400, cors);
        const emailErr = validateEmail(email);
        if (emailErr) return jsonResponse({ error: emailErr }, 400, cors);

        const { error } = await admin.auth.admin.generateLink({
          type: "recovery",
          email,
        });
        if (error) throw error;
        result = { success: true };
        break;
      }

      case "add_org_member": {
        const { org_id, user_id: member_user_id, role } = params;
        const reqErr = validateRequired(params, ["org_id", "user_id"]);
        if (reqErr) return jsonResponse({ error: reqErr }, 400, cors);

        const { data, error } = await admin
          .from("org_members")
          .insert({ org_id, user_id: member_user_id, role: role ?? "teacher" })
          .select()
          .single();
        if (error) throw error;
        result = data;
        break;
      }

      case "update_org_member": {
        const { member_id, role } = params;
        const reqErr = validateRequired(params, ["member_id", "role"]);
        if (reqErr) return jsonResponse({ error: reqErr }, 400, cors);

        const { data, error } = await admin
          .from("org_members")
          .update({ role })
          .eq("id", member_id)
          .select()
          .single();
        if (error) throw error;
        result = data;
        break;
      }

      case "remove_org_member": {
        const { member_id } = params;
        const reqErr = validateRequired(params, ["member_id"]);
        if (reqErr) return jsonResponse({ error: reqErr }, 400, cors);

        const { error } = await admin
          .from("org_members")
          .delete()
          .eq("id", member_id);
        if (error) throw error;
        result = { success: true };
        break;
      }

      default:
        return jsonResponse({ error: `Unknown action: ${action}` }, 400, cors);
    }

    return jsonResponse(result, 200, cors);
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return jsonResponse({ error: message }, 500, getCorsHeaders(req));
  }
});
