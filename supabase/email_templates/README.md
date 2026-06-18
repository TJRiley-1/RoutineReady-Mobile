# RoutineReady — Supabase Auth Email Templates

On-brand, email-client-safe HTML templates for the 6 Supabase auth emails.
Built against the brand package in **`/brand`** (the single source of truth):
website teal `#1a7f7a`, cream `#faf8f5` background, warm text `#1c2b2a`,
Lora headlines + DM Sans body, the clock-badge wordmark, soft teal-tinted
shadow. Bulletproof table layout + button. If you update `/brand`, re-sync
these templates to match.

## How to install each template

1. Supabase Dashboard → **Authentication → Emails → Templates**
2. Pick the template tab (e.g. "Confirm signup")
3. Set the **Subject** (see table below)
4. Open the matching `.html` file, copy the **entire** contents, paste into the
   message body box (toggle to source/HTML view if shown)
5. **Save** and send a test

## Templates, subjects & variables

| Supabase tab | File | Suggested subject | Variables used |
|---|---|---|---|
| Confirm signup | `confirm-signup.html` | Confirm your RoutineReady email | `{{ .ConfirmationURL }}` |
| Invite user | `invite-user.html` | You've been invited to RoutineReady | `{{ .ConfirmationURL }}` |
| Magic Link | `magic-link.html` | Your RoutineReady sign-in link | `{{ .ConfirmationURL }}` |
| Change Email Address | `change-email.html` | Confirm your email change | `{{ .ConfirmationURL }}` `{{ .Email }}` `{{ .NewEmail }}` |
| Reset Password | `reset-password.html` | Reset your RoutineReady password | `{{ .ConfirmationURL }}` |
| Reauthentication | `reauthentication.html` | Your RoutineReady verification code | `{{ .Token }}` |

## Notes

- **Reauthentication shows a 6-digit code, not a link** — Supabase only exposes
  `{{ .Token }}` for this email, there is no URL variable. All others are
  link-based with a copy/paste fallback link.
- **Fonts:** Lora + DM Sans are loaded from Google Fonts and render in Apple
  Mail / iOS Mail. Clients that block web fonts (Gmail, Outlook) fall back
  gracefully to `Georgia` (headlines) and a system sans stack (body) — so the
  emails always look right, just slightly different type off-brand-font clients.
  The bundled Twinkl handwriting fonts are for the in-app display only, not email.
- **OTP option:** if you later switch Magic Link to code entry, swap the button
  block for the code box from `reauthentication.html` and use `{{ .Token }}`.
- **Logo:** uses a styled text wordmark (no image) so nothing can break or be
  blocked. To add a real logo image later, host a PNG and drop an `<img>` into
  the teal header bar in each file.
- **Preview locally:** open any `.html` in a browser. The `{{ .Variable }}`
  placeholders show as literal text until Supabase fills them at send time.
