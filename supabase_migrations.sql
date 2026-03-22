-- RoutineReady Mobile - Database Migrations
-- Run in Supabase SQL Editor

-- 1. Add missing columns to display_settings
ALTER TABLE display_settings ADD COLUMN IF NOT EXISTS top_banner_height int DEFAULT 48;
ALTER TABLE display_settings ADD COLUMN IF NOT EXISTS bottom_banner_height int DEFAULT 48;
ALTER TABLE display_settings ADD COLUMN IF NOT EXISTS selected_sprite text DEFAULT 'penguin';
ALTER TABLE display_settings ADD COLUMN IF NOT EXISTS selected_surface text DEFAULT 'ice';
ALTER TABLE display_settings ADD COLUMN IF NOT EXISTS road_height int DEFAULT 32;

-- 2. Display Sessions - tracks active device connections
CREATE TABLE IF NOT EXISTS display_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools ON DELETE CASCADE,
  device_id text NOT NULL,
  device_name text DEFAULT 'Display',
  session_type text NOT NULL DEFAULT 'display',  -- 'display' or 'admin_only'
  is_active boolean DEFAULT true,
  last_heartbeat timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  UNIQUE(school_id, device_id)
);

ALTER TABLE display_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own school sessions"
  ON display_sessions FOR ALL
  USING (school_id IN (SELECT id FROM schools WHERE owner_id = auth.uid()));

-- 3. Subscriptions - licensing/slot limits
CREATE TABLE IF NOT EXISTS subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools ON DELETE CASCADE,
  plan text DEFAULT 'free',
  max_display_slots int DEFAULT 1,
  max_admin_slots int DEFAULT 1,
  status text DEFAULT 'active',
  expires_at timestamptz,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own subscription"
  ON subscriptions FOR SELECT
  USING (school_id IN (SELECT id FROM schools WHERE owner_id = auth.uid()));

-- 4. Enable Realtime on sync-critical tables
ALTER PUBLICATION supabase_realtime ADD TABLE active_timeline;
ALTER PUBLICATION supabase_realtime ADD TABLE display_settings;
ALTER PUBLICATION supabase_realtime ADD TABLE custom_themes;

-- 5. Add updated_at triggers for change detection
ALTER TABLE active_timeline ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();
ALTER TABLE display_settings ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at BEFORE UPDATE ON active_timeline
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON display_settings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
