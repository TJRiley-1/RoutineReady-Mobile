import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';

class IconEntry {
  final String id;
  final String name;
  final IconData icon;

  const IconEntry({required this.id, required this.name, required this.icon});
}

final List<IconEntry> iconLibrary = [
  IconEntry(id: 'book', name: 'Book', icon: LucideIcons.bookOpen),
  IconEntry(id: 'pencil', name: 'Pencil', icon: LucideIcons.pencil),
  IconEntry(id: 'calculator', name: 'Calculator', icon: LucideIcons.calculator),
  IconEntry(id: 'palette', name: 'Art', icon: LucideIcons.palette),
  IconEntry(id: 'music', name: 'Music', icon: LucideIcons.music),
  IconEntry(id: 'flask', name: 'Science', icon: LucideIcons.flaskConical),
  IconEntry(id: 'apple', name: 'Snack', icon: LucideIcons.apple),
  IconEntry(id: 'utensils', name: 'Lunch', icon: LucideIcons.utensils),
  IconEntry(id: 'running', name: 'PE/Sports', icon: LucideIcons.personStanding),
  IconEntry(id: 'tree', name: 'Outdoor', icon: LucideIcons.trees),
  IconEntry(id: 'computer', name: 'Computer', icon: LucideIcons.monitor),
  IconEntry(id: 'users', name: 'Group Work', icon: LucideIcons.users),
  IconEntry(id: 'sun', name: 'Morning', icon: LucideIcons.sun),
  IconEntry(id: 'moon', name: 'Afternoon', icon: LucideIcons.moon),
  IconEntry(id: 'home', name: 'Home Time', icon: LucideIcons.home),
  IconEntry(id: 'bus', name: 'Bus', icon: LucideIcons.bus),
  IconEntry(id: 'backpack', name: 'Backpack', icon: LucideIcons.backpack),
  IconEntry(id: 'circle', name: 'Circle Time', icon: LucideIcons.circleDot),
  IconEntry(id: 'brain', name: 'Thinking', icon: LucideIcons.brain),
  IconEntry(id: 'hand', name: 'Hand Raise', icon: LucideIcons.hand),
  IconEntry(id: 'star', name: 'Star/Award', icon: LucideIcons.star),
  IconEntry(id: 'heart', name: 'Wellness', icon: LucideIcons.heart),
  IconEntry(id: 'globe', name: 'Geography', icon: LucideIcons.globe),
  IconEntry(id: 'language', name: 'Language', icon: LucideIcons.languages),
];

IconData? getIconData(String? iconId) {
  if (iconId == null) return null;
  final entry = iconLibrary.where((i) => i.id == iconId).firstOrNull;
  return entry?.icon;
}

String? getIconName(String? iconId) {
  if (iconId == null) return null;
  final entry = iconLibrary.where((i) => i.id == iconId).firstOrNull;
  return entry?.name;
}
