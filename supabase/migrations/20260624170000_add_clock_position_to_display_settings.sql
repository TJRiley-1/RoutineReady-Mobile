-- Live clock placement for the display banner: 'top' or 'bottom'. Per-template
-- (lives in settings_json); this column keeps the full display_settings write
-- (backup/import) symmetric and provides the default for ad-hoc timelines.
ALTER TABLE display_settings
  ADD COLUMN IF NOT EXISTS clock_position text NOT NULL DEFAULT 'top';
