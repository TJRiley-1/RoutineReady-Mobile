import 'package:flutter/material.dart';
import '../utils/theme_utils.dart';

class SpritePreset {
  final String id;
  final String emoji;
  final String label;

  const SpritePreset({required this.id, required this.emoji, required this.label});
}

class SurfacePreset {
  final String id;
  final String label;
  final List<Color> gradientColors;

  const SurfacePreset({
    required this.id,
    required this.label,
    required this.gradientColors,
  });
}

final List<SpritePreset> spritePresets = [
  SpritePreset(id: 'penguin', emoji: '\u{1F427}', label: 'Penguin'),
  SpritePreset(id: 'car', emoji: '\u{1F697}', label: 'Car'),
  SpritePreset(id: 'dog', emoji: '\u{1F415}', label: 'Dog'),
  SpritePreset(id: 'cat', emoji: '\u{1F408}', label: 'Cat'),
  SpritePreset(id: 'bird', emoji: '\u{1F426}', label: 'Bird'),
  SpritePreset(id: 'rabbit', emoji: '\u{1F407}', label: 'Rabbit'),
  SpritePreset(id: 'horse', emoji: '\u{1F40E}', label: 'Horse'),
  SpritePreset(id: 'snail', emoji: '\u{1F40C}', label: 'Snail'),
  SpritePreset(id: 'rocket', emoji: '\u{1F680}', label: 'Rocket'),
  SpritePreset(id: 'bicycle', emoji: '\u{1F6B2}', label: 'Bicycle'),
];

final List<SurfacePreset> surfacePresets = [
  SurfacePreset(id: 'ice', label: 'Ice', gradientColors: [parseHexColor('#e0f2fe'), parseHexColor('#bae6fd'), parseHexColor('#e0f2fe')]),
  SurfacePreset(id: 'tarmac', label: 'Tarmac Road', gradientColors: [parseHexColor('#4b5563'), parseHexColor('#374151'), parseHexColor('#4b5563')]),
  SurfacePreset(id: 'gravel', label: 'Gravel Road', gradientColors: [parseHexColor('#a8a29e'), parseHexColor('#78716c'), parseHexColor('#a8a29e')]),
  SurfacePreset(id: 'grass', label: 'Grass', gradientColors: [parseHexColor('#86efac'), parseHexColor('#4ade80'), parseHexColor('#86efac')]),
  SurfacePreset(id: 'sand', label: 'Sand', gradientColors: [parseHexColor('#fde68a'), parseHexColor('#fcd34d'), parseHexColor('#fde68a')]),
  SurfacePreset(id: 'water', label: 'Water', gradientColors: [parseHexColor('#93c5fd'), parseHexColor('#60a5fa'), parseHexColor('#93c5fd')]),
];

Color getSurfaceDashColor(String surfaceId) {
  switch (surfaceId) {
    case 'ice':
      return parseHexColor('#94a3b8');
    case 'tarmac':
      return Colors.white;
    case 'gravel':
      return parseHexColor('#d6d3d1');
    case 'grass':
      return Colors.white;
    case 'sand':
      return parseHexColor('#92400e');
    case 'water':
      return parseHexColor('#dbeafe');
    default:
      return Colors.white;
  }
}

String getSpriteEmoji(String spriteId) {
  final preset = spritePresets.where((s) => s.id == spriteId).firstOrNull;
  return preset?.emoji ?? '\u{1F427}';
}

List<Color> getSurfaceGradientColors(String surfaceId) {
  final preset = surfacePresets.where((s) => s.id == surfaceId).firstOrNull;
  return preset?.gradientColors ?? surfacePresets[0].gradientColors;
}
