-- Multi-row mode: force a new row to start after this task (manual row breaks).
ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS break_after boolean NOT NULL DEFAULT false;
