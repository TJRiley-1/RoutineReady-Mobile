import 'package:flutter/material.dart';
import '../../data/icon_library.dart';
import '../../models/task.dart';
import '../../models/theme_config.dart';
import '../../utils/theme_utils.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final ThemeConfig theme;
  final bool isCurrent;
  final bool isPast;
  final int index;
  final double? overrideWidth;
  final double? overrideHeight;

  const TaskCard({
    super.key,
    required this.task,
    required this.theme,
    this.isCurrent = false,
    this.isPast = false,
    this.index = 0,
    this.overrideWidth,
    this.overrideHeight,
  });

  @override
  Widget build(BuildContext context) {
    final taskWidth = overrideWidth ?? task.width.toDouble();
    final taskHeight = overrideHeight ?? task.height.toDouble();

    final borderColor = theme.cardBorderColorAlt != null && index % 2 == 1
        ? parseHexColor(theme.cardBorderColorAlt!)
        : parseHexColor(theme.cardBorderColor);

    final borderWidth = theme.borderWidthValue;

    Color bgColor;
    if (isCurrent) {
      bgColor = parseColorString(theme.currentBgOverlay);
    } else if (isPast) {
      bgColor = const Color(0xFFF3F4F6);
    } else {
      bgColor = parseHexColor(theme.cardBgColor);
    }

    final effectiveBorderWidth =
        isCurrent && theme.currentBorderEnhance ? borderWidth * 1.5 : borderWidth;
    final effectiveBorderColor = isCurrent && theme.currentBorderEnhance
        ? parseHexColor(theme.currentGlowColor)
        : borderColor;

    final iconSize = (taskWidth * 0.5).clamp(24.0, 80.0);
    final fontSize = (taskWidth / 5).clamp(12.0, 36.0);
    final durationFontSize = (taskWidth / 10).clamp(10.0, 20.0);

    final iconData = getIconData(task.icon);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      width: taskWidth,
      constraints: BoxConstraints(minHeight: taskHeight),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(
          color: effectiveBorderColor,
          width: effectiveBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? parseHexColor(theme.currentGlowColor).withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: isCurrent ? 30 : 8,
            spreadRadius: isCurrent ? 2 : 0,
          ),
        ],
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: isPast ? 0.6 : 1.0,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 500),
          scale: isCurrent ? 1.05 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (task.type == 'image' && task.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      task.imageUrl!,
                      width: (taskWidth * 0.7).clamp(0, 128),
                      height: (taskHeight * 0.6).clamp(0, 128),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image_not_supported,
                        size: iconSize,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ] else ...[
                  if (iconData != null) ...[
                    Icon(
                      iconData,
                      size: iconSize,
                      color: parseHexColor(theme.cardBorderColor),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    theme.fontTransform == 'uppercase'
                        ? task.content.toUpperCase()
                        : task.content,
                    textAlign: TextAlign.center,
                    style: getThemeTextStyle(theme, fontSize).copyWith(
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  '${task.duration} min',
                  style: TextStyle(
                    fontSize: durationFontSize,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
