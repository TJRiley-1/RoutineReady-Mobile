-- Retire the concurrent-display slot system. Display-count licensing is now
-- enforced by the number of classrooms RoutineReady staff create (one classroom
-- = one paid display) plus the per-classroom `schools.is_active` switch, so the
-- session/heartbeat table is no longer used by the app.
DROP TABLE IF EXISTS display_sessions CASCADE;
