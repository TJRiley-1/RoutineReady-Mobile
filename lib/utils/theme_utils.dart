import 'package:flutter/material.dart';
import '../data/preset_themes.dart';
import '../models/theme_config.dart';

ThemeConfig getActiveTheme(String currentTheme, List<ThemeConfig> customThemes) {
  if (presetThemes.containsKey(currentTheme)) {
    return presetThemes[currentTheme]!;
  }
  final custom = customThemes.where((t) => t.id == currentTheme).firstOrNull;
  return custom ?? presetThemes['routine-ready']!;
}

String getThemeName(String currentTheme, List<ThemeConfig> customThemes) {
  return getActiveTheme(currentTheme, customThemes).name;
}

String getThemeEmoji(String currentTheme, List<ThemeConfig> customThemes) {
  final theme = getActiveTheme(currentTheme, customThemes);
  return theme.emoji.isEmpty ? '\u{1F3A8}' : theme.emoji;
}

Color parseHexColor(String hex) {
  hex = hex.replaceFirst('#', '');
  if (hex.length == 6) {
    return Color(int.parse('FF$hex', radix: 16));
  }
  if (hex.length == 8) {
    return Color(int.parse(hex, radix: 16));
  }
  return Colors.grey;
}

Color parseColorString(String colorStr) {
  if (colorStr.startsWith('#')) {
    return parseHexColor(colorStr);
  }
  if (colorStr.startsWith('rgba')) {
    final match =
        RegExp(r'rgba?\((\d+),\s*(\d+),\s*(\d+),?\s*([\d.]+)?\)')
            .firstMatch(colorStr);
    if (match != null) {
      final r = int.parse(match.group(1)!);
      final g = int.parse(match.group(2)!);
      final b = int.parse(match.group(3)!);
      final a = match.group(4) != null
          ? (double.parse(match.group(4)!) * 255).round()
          : 255;
      return Color.fromARGB(a, r, g, b);
    }
  }
  return Colors.grey;
}

LinearGradient getBackgroundGradient(ThemeConfig theme) {
  final colors = <Color>[
    parseHexColor(theme.bgGradientFrom),
    if (theme.bgGradientVia != null) parseHexColor(theme.bgGradientVia!),
    parseHexColor(theme.bgGradientTo),
  ];
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: colors,
  );
}

FontWeight mapFontWeight(String weight) {
  switch (weight) {
    case '300':
      return FontWeight.w300;
    case '400':
      return FontWeight.w400;
    case '500':
      return FontWeight.w500;
    case '600':
      return FontWeight.w600;
    case '700':
      return FontWeight.w700;
    case '800':
      return FontWeight.w800;
    default:
      return FontWeight.w500;
  }
}

TextStyle getThemeTextStyle(ThemeConfig theme, double baseFontSize) {
  return TextStyle(
    fontWeight: mapFontWeight(theme.fontWeight),
    fontSize: baseFontSize,
    letterSpacing: 0,
  );
}
