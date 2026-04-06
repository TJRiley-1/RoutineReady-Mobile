import 'package:flutter_test/flutter_test.dart';
import 'package:routine_ready/models/task.dart';
import 'package:routine_ready/models/template.dart';
import 'package:routine_ready/models/active_timeline.dart';
import 'package:routine_ready/models/display_settings.dart';
import 'package:routine_ready/models/weekly_schedule.dart';
import 'package:routine_ready/models/school.dart';
import 'package:routine_ready/models/organization.dart';
import 'package:routine_ready/models/org_member.dart';
import 'package:routine_ready/models/display_session.dart';
import 'package:routine_ready/models/subscription.dart';
import 'package:routine_ready/models/theme_config.dart';

void main() {
  // ─── Task ───

  group('Task', () {
    test('fromJson with all fields', () {
      final task = Task.fromJson({
        'id': 'abc-123',
        'type': 'image',
        'content': 'Maths',
        'duration': 45,
        'imageUrl': 'https://example.com/img.png',
        'icon': 'book',
        'width': 300,
        'height': 200,
      });
      expect(task.id, 'abc-123');
      expect(task.type, 'image');
      expect(task.content, 'Maths');
      expect(task.duration, 45);
      expect(task.imageUrl, 'https://example.com/img.png');
      expect(task.icon, 'book');
      expect(task.width, 300);
      expect(task.height, 200);
    });

    test('fromJson with defaults for missing fields', () {
      final task = Task.fromJson({'id': 1});
      expect(task.type, 'text');
      expect(task.content, 'New Task');
      expect(task.duration, 30);
      expect(task.imageUrl, isNull);
      expect(task.icon, isNull);
      expect(task.width, 200);
      expect(task.height, 160);
    });

    test('fromJson reads snake_case image_url as fallback', () {
      final task = Task.fromJson({
        'id': 1,
        'image_url': 'https://example.com/snake.png',
      });
      expect(task.imageUrl, 'https://example.com/snake.png');
    });

    test('fromJson prefers camelCase imageUrl over snake_case', () {
      final task = Task.fromJson({
        'id': 1,
        'imageUrl': 'camel',
        'image_url': 'snake',
      });
      expect(task.imageUrl, 'camel');
    });

    test('toJson roundtrip', () {
      final original = Task(
        id: 'x',
        type: 'image',
        content: 'Reading',
        duration: 20,
        imageUrl: 'https://img.test/a.png',
        icon: 'star',
        width: 250,
        height: 180,
      );
      final json = original.toJson();
      final restored = Task.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.content, original.content);
      expect(restored.duration, original.duration);
      expect(restored.imageUrl, original.imageUrl);
      expect(restored.icon, original.icon);
      expect(restored.width, original.width);
      expect(restored.height, original.height);
    });

    test('copyWith overrides specified fields only', () {
      final task = Task(id: 1, content: 'Original', duration: 30);
      final copy = task.copyWith(content: 'Changed', duration: 15);
      expect(copy.content, 'Changed');
      expect(copy.duration, 15);
      expect(copy.id, 1); // unchanged
      expect(copy.type, 'text'); // unchanged
    });

    test('copyWith clearImageUrl removes image', () {
      final task = Task(id: 1, imageUrl: 'https://img.test/a.png');
      final copy = task.copyWith(clearImageUrl: true);
      expect(copy.imageUrl, isNull);
    });
  });

  // ─── TaskTemplate ───

  group('TaskTemplate', () {
    test('fromJson with camelCase keys', () {
      final t = TaskTemplate.fromJson({
        'id': 'tpl-1',
        'name': 'Morning',
        'startTime': '09:00',
        'endTime': '11:00',
        'tasks': [
          {'id': 1, 'content': 'Task 1', 'duration': 30},
        ],
      });
      expect(t.name, 'Morning');
      expect(t.startTime, '09:00');
      expect(t.endTime, '11:00');
      expect(t.tasks.length, 1);
    });

    test('fromJson with snake_case keys (DB format)', () {
      final t = TaskTemplate.fromJson({
        'id': 'tpl-2',
        'name': 'Afternoon',
        'start_time': '13:00',
        'end_time': '15:00',
      });
      expect(t.startTime, '13:00');
      expect(t.endTime, '15:00');
    });

    test('fromJson defaults', () {
      final t = TaskTemplate.fromJson({'id': 'x'});
      expect(t.name, 'Untitled');
      expect(t.startTime, '08:00');
      expect(t.endTime, '10:30');
      expect(t.tasks, isEmpty);
    });

    test('toJson roundtrip', () {
      final original = TaskTemplate(
        id: 'tpl-1',
        name: 'Test',
        startTime: '08:30',
        endTime: '09:30',
        tasks: [Task(id: 1, content: 'A', duration: 60)],
      );
      final restored = TaskTemplate.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.startTime, original.startTime);
      expect(restored.tasks.length, 1);
      expect(restored.tasks[0].content, 'A');
    });
  });

  // ─── ActiveTimeline ───

  group('ActiveTimeline', () {
    test('fromJson with DB format (snake_case + tasks_json)', () {
      final t = ActiveTimeline.fromJson({
        'start_time': '08:00',
        'end_time': '10:00',
        'tasks_json': [
          {'id': 1, 'content': 'Phonics', 'duration': 20},
          {'id': 2, 'content': 'Maths', 'duration': 40},
        ],
      });
      expect(t.startTime, '08:00');
      expect(t.endTime, '10:00');
      expect(t.tasks.length, 2);
      expect(t.tasks[0].content, 'Phonics');
    });

    test('fromJson with camelCase format (from toJson)', () {
      final t = ActiveTimeline.fromJson({
        'startTime': '09:00',
        'endTime': '11:00',
        'tasks': [
          {'id': 1, 'content': 'Art', 'duration': 30},
        ],
      });
      expect(t.startTime, '09:00');
      expect(t.endTime, '11:00');
      expect(t.tasks.length, 1);
    });

    test('fromJson prefers snake_case over camelCase', () {
      final t = ActiveTimeline.fromJson({
        'start_time': 'snake',
        'startTime': 'camel',
        'end_time': 'snake_end',
        'endTime': 'camel_end',
        'tasks': [],
      });
      expect(t.startTime, 'snake');
      expect(t.endTime, 'snake_end');
    });

    test('fromJson defaults for empty map', () {
      final t = ActiveTimeline.fromJson({});
      expect(t.startTime, '08:00');
      expect(t.endTime, '10:30');
      expect(t.tasks, isEmpty);
    });

    test('toJson roundtrip', () {
      final original = ActiveTimeline(
        startTime: '07:30',
        endTime: '09:00',
        tasks: [Task(id: 'a', content: 'Wake up', duration: 10)],
      );
      final restored = ActiveTimeline.fromJson(original.toJson());
      expect(restored.startTime, '07:30');
      expect(restored.endTime, '09:00');
      expect(restored.tasks.length, 1);
    });
  });

  // ─── DisplaySettings ───

  group('DisplaySettings', () {
    test('defaults', () {
      const ds = DisplaySettings();
      expect(ds.width, 2560);
      expect(ds.height, 1080);
      expect(ds.scale, 100);
      expect(ds.mode, 'horizontal');
      expect(ds.rows, 1);
      expect(ds.showClock, false);
      expect(ds.autoOptimise, false);
      expect(ds.selectedSprite, 'penguin');
      expect(ds.selectedSurface, 'ice');
    });

    test('fromDbJson with all fields', () {
      final ds = DisplaySettings.fromDbJson({
        'width': 3840,
        'height': 1080,
        'scale': 120,
        'mode': 'auto-pan',
        'rows': 2,
        'path_direction': 'snake',
        'transition_type': 'sprite',
        'show_clock': true,
        'auto_pan_tile_height': 80,
        'selected_sprite': 'car',
        'selected_surface': 'road',
        'road_height': 40,
        'auto_optimise': true,
      });
      expect(ds.width, 3840);
      expect(ds.mode, 'auto-pan');
      expect(ds.pathDirection, 'snake');
      expect(ds.showClock, true);
      expect(ds.selectedSprite, 'car');
      expect(ds.autoOptimise, true);
    });

    test('fromDbJson defaults for missing fields', () {
      final ds = DisplaySettings.fromDbJson({});
      expect(ds.width, 2560);
      expect(ds.mode, 'horizontal');
    });

    test('toDbJson roundtrip', () {
      const original = DisplaySettings(
        width: 1920,
        height: 540,
        mode: 'multi-row',
        rows: 3,
        showClock: true,
      );
      final restored = DisplaySettings.fromDbJson(original.toDbJson());
      expect(restored.width, 1920);
      expect(restored.height, 540);
      expect(restored.mode, 'multi-row');
      expect(restored.rows, 3);
      expect(restored.showClock, true);
    });

    test('copyWith', () {
      const ds = DisplaySettings();
      final copy = ds.copyWith(width: 3840, mode: 'auto-pan');
      expect(copy.width, 3840);
      expect(copy.mode, 'auto-pan');
      expect(copy.height, 1080); // unchanged
    });
  });

  // ─── WeeklySchedule ───

  group('WeeklySchedule', () {
    test('fromJson', () {
      final ws = WeeklySchedule.fromJson({
        'monday': 'tpl-1',
        'tuesday': 'tpl-2',
        'wednesday': null,
        'thursday': 'tpl-1',
        'friday': 'tpl-3',
      });
      expect(ws.monday, 'tpl-1');
      expect(ws.tuesday, 'tpl-2');
      expect(ws.wednesday, isNull);
      expect(ws.thursday, 'tpl-1');
      expect(ws.friday, 'tpl-3');
    });

    test('toJson roundtrip', () {
      final original = WeeklySchedule(
        monday: 'a',
        wednesday: 'b',
        friday: 'c',
      );
      final restored = WeeklySchedule.fromJson(original.toJson());
      expect(restored.monday, 'a');
      expect(restored.tuesday, isNull);
      expect(restored.wednesday, 'b');
      expect(restored.friday, 'c');
    });

    test('getForDay returns correct template ID', () {
      final ws = WeeklySchedule(monday: 'tpl-1', friday: 'tpl-5');
      expect(ws.getForDay('monday'), 'tpl-1');
      expect(ws.getForDay('friday'), 'tpl-5');
      expect(ws.getForDay('tuesday'), isNull);
      expect(ws.getForDay('saturday'), isNull);
    });

    test('setForDay replaces only the specified day', () {
      final ws = WeeklySchedule(monday: 'old', tuesday: 'keep');
      final updated = ws.setForDay('monday', 'new');
      expect(updated.monday, 'new');
      expect(updated.tuesday, 'keep');
    });

    test('setForDay can clear a day', () {
      final ws = WeeklySchedule(monday: 'tpl-1');
      final cleared = ws.setForDay('monday', null);
      expect(cleared.monday, isNull);
    });

    test('remapIds updates matching IDs', () {
      final ws = WeeklySchedule(
        monday: 'old-1',
        tuesday: 'old-2',
        wednesday: 'keep-3',
      );
      final remapped = ws.remapIds({'old-1': 'new-1', 'old-2': 'new-2'});
      expect(remapped.monday, 'new-1');
      expect(remapped.tuesday, 'new-2');
      expect(remapped.wednesday, 'keep-3'); // not in map, unchanged
    });

    test('remapIds leaves null days as null', () {
      final ws = WeeklySchedule();
      final remapped = ws.remapIds({'old': 'new'});
      expect(remapped.monday, isNull);
      expect(remapped.friday, isNull);
    });
  });

  // ─── School ───

  group('School', () {
    test('fromJson', () {
      final s = School.fromJson({
        'id': 'sch-1',
        'owner_id': 'usr-1',
        'org_id': 'org-1',
        'school_name': 'Oak Primary',
        'class_name': 'Hedgehogs',
        'teacher_name': 'Ms Smith',
        'device_name': 'Classroom TV',
      });
      expect(s.id, 'sch-1');
      expect(s.ownerId, 'usr-1');
      expect(s.orgId, 'org-1');
      expect(s.schoolName, 'Oak Primary');
      expect(s.className, 'Hedgehogs');
      expect(s.teacherName, 'Ms Smith');
      expect(s.deviceName, 'Classroom TV');
    });

    test('fromJson defaults', () {
      final s = School.fromJson({
        'id': 'sch-1',
        'owner_id': 'usr-1',
      });
      expect(s.orgId, isNull);
      expect(s.schoolName, '');
      expect(s.className, '');
      expect(s.teacherName, '');
      expect(s.deviceName, 'Display 1');
    });

    test('toJson excludes id, includes org_id only when present', () {
      final s = School(
        id: 'sch-1',
        ownerId: 'usr-1',
        schoolName: 'Test',
        className: 'Class',
        teacherName: 'Teacher',
      );
      final json = s.toJson();
      expect(json.containsKey('id'), false);
      expect(json.containsKey('org_id'), false);
      expect(json['owner_id'], 'usr-1');
    });

    test('toJson includes org_id when present', () {
      final s = School(
        id: 'sch-1',
        ownerId: 'usr-1',
        orgId: 'org-1',
        schoolName: '',
        className: '',
        teacherName: '',
      );
      expect(s.toJson()['org_id'], 'org-1');
    });

    test('copyWith', () {
      final s = School(
        id: 'sch-1',
        ownerId: 'usr-1',
        schoolName: 'Old',
        className: 'Old',
        teacherName: 'Old',
      );
      final copy = s.copyWith(schoolName: 'New');
      expect(copy.schoolName, 'New');
      expect(copy.className, 'Old'); // unchanged
      expect(copy.id, 'sch-1'); // immutable
    });
  });

  // ─── Organization ───

  group('Organization', () {
    test('fromJson', () {
      final o = Organization.fromJson({'id': 'org-1', 'name': 'Academy Trust'});
      expect(o.id, 'org-1');
      expect(o.name, 'Academy Trust');
    });

    test('fromJson defaults empty name', () {
      final o = Organization.fromJson({'id': 'org-1'});
      expect(o.name, '');
    });

    test('toJson excludes id', () {
      final o = Organization(id: 'org-1', name: 'Test');
      final json = o.toJson();
      expect(json.containsKey('id'), false);
      expect(json['name'], 'Test');
    });
  });

  // ─── OrgMember & UserRole ───

  group('OrgMember', () {
    test('fromJson', () {
      final m = OrgMember.fromJson({
        'id': 'mem-1',
        'org_id': 'org-1',
        'user_id': 'usr-1',
        'role': 'teacher',
      });
      expect(m.id, 'mem-1');
      expect(m.role, UserRole.teacher);
    });

    test('fromJson defaults role to staff', () {
      final m = OrgMember.fromJson({
        'id': 'mem-1',
        'org_id': 'org-1',
        'user_id': 'usr-1',
      });
      expect(m.role, UserRole.staff);
    });

    test('role permissions — teacher', () {
      final m = OrgMember.fromJson({
        'id': '1',
        'org_id': '1',
        'user_id': '1',
        'role': 'teacher',
      });
      expect(m.canEdit, true);
      expect(m.canSave, true);
      expect(m.canAccessAdmin, true);
      expect(m.isDisplayOnly, false);
      expect(m.isSessionOnly, false);
    });

    test('role permissions — staff', () {
      final m = OrgMember.fromJson({
        'id': '1',
        'org_id': '1',
        'user_id': '1',
        'role': 'staff',
      });
      expect(m.canEdit, true);
      expect(m.canSave, false);
      expect(m.canAccessAdmin, false);
      expect(m.isSessionOnly, true);
    });

    test('role permissions — display', () {
      final m = OrgMember.fromJson({
        'id': '1',
        'org_id': '1',
        'user_id': '1',
        'role': 'display',
      });
      expect(m.canEdit, false);
      expect(m.canSave, false);
      expect(m.isDisplayOnly, true);
    });

    test('role permissions — school_admin', () {
      final m = OrgMember.fromJson({
        'id': '1',
        'org_id': '1',
        'user_id': '1',
        'role': 'school_admin',
      });
      expect(m.role, UserRole.schoolAdmin);
      expect(m.canEdit, false);
      expect(m.canSave, false);
    });
  });

  group('UserRole', () {
    test('fromString parses all roles', () {
      expect(UserRole.fromString('teacher'), UserRole.teacher);
      expect(UserRole.fromString('staff'), UserRole.staff);
      expect(UserRole.fromString('display'), UserRole.display);
      expect(UserRole.fromString('school_admin'), UserRole.schoolAdmin);
    });

    test('fromString defaults unknown to staff', () {
      expect(UserRole.fromString('unknown'), UserRole.staff);
      expect(UserRole.fromString(''), UserRole.staff);
    });

    test('toDbString roundtrips with fromString', () {
      for (final role in UserRole.values) {
        expect(UserRole.fromString(role.toDbString()), role);
      }
    });
  });

  // ─── DisplaySession ───

  group('DisplaySession', () {
    test('fromJson', () {
      final ds = DisplaySession.fromJson({
        'id': 'ses-1',
        'school_id': 'sch-1',
        'device_id': 'dev-1',
        'device_name': 'Pi Display',
        'session_type': 'display',
        'is_active': true,
        'last_heartbeat': '2026-04-06T10:00:00Z',
        'created_at': '2026-04-06T08:00:00Z',
      });
      expect(ds.id, 'ses-1');
      expect(ds.deviceName, 'Pi Display');
      expect(ds.isActive, true);
      expect(ds.lastHeartbeat.hour, 10);
    });

    test('fromJson defaults', () {
      final ds = DisplaySession.fromJson({
        'id': 'ses-1',
        'school_id': 'sch-1',
        'device_id': 'dev-1',
        'last_heartbeat': '2026-04-06T10:00:00Z',
        'created_at': '2026-04-06T08:00:00Z',
      });
      expect(ds.deviceName, 'Display');
      expect(ds.sessionType, 'display');
      expect(ds.isActive, true);
    });
  });

  // ─── Subscription ───

  group('Subscription', () {
    test('fromJson full', () {
      final s = Subscription.fromJson({
        'id': 'sub-1',
        'school_id': 'sch-1',
        'plan': 'pro',
        'max_display_slots': 3,
        'max_admin_slots': 2,
        'status': 'active',
        'expires_at': '2027-04-06T00:00:00Z',
      });
      expect(s.plan, 'pro');
      expect(s.maxDisplaySlots, 3);
      expect(s.maxAdminSlots, 2);
      expect(s.expiresAt, isNotNull);
      expect(s.expiresAt!.year, 2027);
    });

    test('fromJson defaults', () {
      final s = Subscription.fromJson({
        'id': 'sub-1',
        'school_id': 'sch-1',
      });
      expect(s.plan, 'free');
      expect(s.maxDisplaySlots, 1);
      expect(s.maxAdminSlots, 1);
      expect(s.status, 'active');
      expect(s.expiresAt, isNull);
    });
  });

  // ─── ThemeConfig ───

  group('ThemeConfig', () {
    test('toJson/fromJson roundtrip preserves all fields', () {
      final original = ThemeConfig(
        id: 'theme-1',
        name: 'Ocean',
        emoji: '\u{1F30A}',
        bgGradientFrom: '#0077be',
        bgGradientTo: '#004e92',
        cardBorderColor: '#ffffff',
        currentGlowColor: '#00bfff',
        currentBgOverlay: '#00000033',
        tickPastColor: '#22c55e',
        tickCurrentColor: '#3b82f6',
        tickFutureColor: '#d1d5db',
        timeCardAccentColor: '#0077be',
        progressLineColors: {'past': '#22c55e', 'current': '#3b82f6'},
        fontFamily: 'TwinklCursiveLooped',
        specialEffect: 'bubbles',
      );
      final json = original.toJson();
      final restored = ThemeConfig.fromJson(json);

      expect(restored.id, 'theme-1');
      expect(restored.name, 'Ocean');
      expect(restored.emoji, '\u{1F30A}');
      expect(restored.bgGradientFrom, '#0077be');
      expect(restored.fontFamily, 'TwinklCursiveLooped');
      expect(restored.specialEffect, 'bubbles');
      expect(restored.progressLineColors['past'], '#22c55e');
    });

    test('fromJson defaults for minimal input', () {
      final t = ThemeConfig.fromJson({});
      expect(t.id, '');
      expect(t.name, '');
      expect(t.cardBgColor, '#ffffff');
      expect(t.fontWeight, '500');
      expect(t.fontTransform, 'none');
      expect(t.currentBorderEnhance, false);
    });

    test('borderRadius parsing', () {
      final t = ThemeConfig.fromJson({'cardRounded': 'rounded-lg'});
      expect(t.borderRadius, 12);
    });

    test('borderWidthValue parsing', () {
      final t = ThemeConfig.fromJson({'cardBorderWidth': '3px'});
      expect(t.borderWidthValue, 3.0);
    });

    test('copyWith', () {
      final t = ThemeConfig.fromJson({'id': 'a', 'name': 'Original'});
      final copy = t.copyWith(name: 'Changed', fontFamily: 'TwinklPrecursive');
      expect(copy.name, 'Changed');
      expect(copy.fontFamily, 'TwinklPrecursive');
      expect(copy.id, 'a'); // unchanged
    });
  });
}
