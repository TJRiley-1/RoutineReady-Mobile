import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/active_timeline.dart';
import '../models/display_settings.dart';
import '../models/theme_config.dart';
const _keyTimeline = 'cached_active_timeline';
const _keyDisplaySettings = 'cached_display_settings';
const _keyLastUpdated = 'cached_last_updated';

/// Lightweight cache for display-critical data using shared_preferences.
/// Ensures the classroom display can continue showing the schedule
/// if the internet drops.
class ScheduleCache {
  ScheduleCache._();

  static Future<void> saveTimeline(ActiveTimeline timeline) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTimeline, jsonEncode(timeline.toJson()));
    await prefs.setString(_keyLastUpdated, DateTime.now().toUtc().toIso8601String());
  }

  static Future<void> saveDisplaySettings(
    DisplaySettings settings,
    String currentTheme,
    List<ThemeConfig> customThemes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      ...settings.toDbJson(),
      'current_theme': currentTheme,
      'custom_themes': customThemes.map((t) => t.toJson()).toList(),
    };
    await prefs.setString(_keyDisplaySettings, jsonEncode(data));
    await prefs.setString(_keyLastUpdated, DateTime.now().toUtc().toIso8601String());
  }

  static Future<void> saveAll(
    ActiveTimeline timeline,
    DisplaySettings settings,
    String currentTheme,
    List<ThemeConfig> customThemes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTimeline, jsonEncode(timeline.toJson()));
    final dsData = {
      ...settings.toDbJson(),
      'current_theme': currentTheme,
      'custom_themes': customThemes.map((t) => t.toJson()).toList(),
    };
    await prefs.setString(_keyDisplaySettings, jsonEncode(dsData));
    await prefs.setString(_keyLastUpdated, DateTime.now().toUtc().toIso8601String());
  }

  static Future<ActiveTimeline?> loadTimeline() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyTimeline);
    if (raw == null) return null;
    try {
      return ActiveTimeline.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<CachedDisplayData?> loadDisplaySettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyDisplaySettings);
    if (raw == null) return null;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final settings = DisplaySettings.fromDbJson(data);
      final currentTheme = data['current_theme'] as String? ?? 'routine-ready';
      final customThemes = ((data['custom_themes'] as List?) ?? [])
          .map((t) => ThemeConfig.fromJson(t as Map<String, dynamic>))
          .toList();
      return CachedDisplayData(
        settings: settings,
        currentTheme: currentTheme,
        customThemes: customThemes,
      );
    } catch (_) {
      return null;
    }
  }
}

class CachedDisplayData {
  final DisplaySettings settings;
  final String currentTheme;
  final List<ThemeConfig> customThemes;

  CachedDisplayData({
    required this.settings,
    required this.currentTheme,
    required this.customThemes,
  });
}
