-- Per-template display settings: each template carries its own settings snapshot.
-- mode/transition_type/width/height remain global (display_settings); everything
-- else follows the template. active_timeline carries a live snapshot for realtime
-- + offline display.

ALTER TABLE templates
  ADD COLUMN IF NOT EXISTS settings_json jsonb,
  ADD COLUMN IF NOT EXISTS current_theme text;

ALTER TABLE active_timeline
  ADD COLUMN IF NOT EXISTS settings_json jsonb,
  ADD COLUMN IF NOT EXISTS current_theme text;

-- Backfill so existing templates keep their current look: seed from each
-- school's existing display_settings row.
UPDATE templates t SET
  settings_json = (to_jsonb(ds) - 'id' - 'school_id' - 'created_at' - 'updated_at' - 'current_theme' - 'setup_guide_completed'),
  current_theme = ds.current_theme
FROM display_settings ds
WHERE ds.school_id = t.school_id
  AND t.settings_json IS NULL;

UPDATE active_timeline a SET
  settings_json = (to_jsonb(ds) - 'id' - 'school_id' - 'created_at' - 'updated_at' - 'current_theme' - 'setup_guide_completed'),
  current_theme = ds.current_theme
FROM display_settings ds
WHERE ds.school_id = a.school_id
  AND a.settings_json IS NULL;
