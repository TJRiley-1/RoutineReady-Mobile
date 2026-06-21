
ALTER TABLE display_settings
  ADD COLUMN IF NOT EXISTS auto_optimise boolean NOT NULL DEFAULT false;
