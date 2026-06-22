-- Per-task transition width multiplier (visual only; does not affect timing).
ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS transition_scale double precision NOT NULL DEFAULT 1.0;
