-- End card ("Home Time") shown at the end of a timeline. A full editable card
-- stored outside the tasks list. Per-template; on by default.
ALTER TABLE templates
  ADD COLUMN IF NOT EXISTS end_card_json jsonb;
ALTER TABLE active_timeline
  ADD COLUMN IF NOT EXISTS end_card_json jsonb;

-- Backfill existing rows so they show the default Home Time card (on by default).
UPDATE templates SET end_card_json =
  '{"enabled": true, "task": {"id": "end-card", "type": "icon", "content": "Home Time", "duration": 0, "icon": "home", "imageUrl": null, "width": 200, "height": 160, "breakAfter": false}}'::jsonb
WHERE end_card_json IS NULL;

UPDATE active_timeline SET end_card_json =
  '{"enabled": true, "task": {"id": "end-card", "type": "icon", "content": "Home Time", "duration": 0, "icon": "home", "imageUrl": null, "width": 200, "height": 160, "breakAfter": false}}'::jsonb
WHERE end_card_json IS NULL;
