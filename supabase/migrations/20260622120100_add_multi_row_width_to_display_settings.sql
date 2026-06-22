-- Multi-row mode: usable row width as a percentage of display width. Per-template
-- (lives in settings_json); this column keeps the full display_settings write
-- (backup/import) symmetric and provides the default for ad-hoc timelines.
-- NOTE: superseded by per-transition width (transition_scale); column retained.
ALTER TABLE display_settings
  ADD COLUMN IF NOT EXISTS multi_row_width integer NOT NULL DEFAULT 100;
