import 'package:flutter/material.dart';
import '../../data/icon_library.dart';
import '../../models/active_timeline.dart';
import '../../models/display_settings.dart';
import '../../models/theme_config.dart';
import '../../utils/theme_utils.dart';
import '../../widgets/display/banner_bar.dart';
import '../../widgets/display/transition_indicator.dart';

class AutoPanDisplay extends StatelessWidget {
  final ActiveTimeline timeline;
  final DisplaySettings displaySettings;
  final ThemeConfig theme;
  final int currentTaskIndex;
  final double elapsedInTask;

  const AutoPanDisplay({
    super.key,
    required this.timeline,
    required this.displaySettings,
    required this.theme,
    required this.currentTaskIndex,
    required this.elapsedInTask,
  });

  @override
  Widget build(BuildContext context) {
    final currentTask =
        currentTaskIndex >= 0 && currentTaskIndex < timeline.tasks.length
            ? timeline.tasks[currentTaskIndex]
            : null;
    final nextTask = currentTaskIndex + 1 < timeline.tasks.length
        ? timeline.tasks[currentTaskIndex + 1]
        : null;

    final borderColor = parseHexColor(theme.cardBorderColor);
    final glowColor = parseHexColor(theme.currentGlowColor);

    return Column(
      children: [
        // Top Banner
        BannerBar(
          imageUrl: displaySettings.topBannerImage,
          height: displaySettings.topBannerHeight,
          theme: theme,
          showClock: displaySettings.showClock,
          isTop: true,
        ),

        // Main content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Current task (flex 1)
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: parseColorString(theme.currentBgOverlay),
                      borderRadius: BorderRadius.circular(theme.borderRadius),
                      border: Border.all(
                        color: theme.currentBorderEnhance
                            ? glowColor
                            : borderColor,
                        width: theme.borderWidthValue * 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withValues(alpha: 0.4),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: currentTask != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'CURRENT TASK',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: glowColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (currentTask.icon != null)
                                Icon(
                                  getIconData(currentTask.icon),
                                  size: 80,
                                  color: borderColor,
                                ),
                              const SizedBox(height: 16),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  theme.fontTransform == 'uppercase'
                                      ? currentTask.content.toUpperCase()
                                      : currentTask.content,
                                  textAlign: TextAlign.center,
                                  style: getThemeTextStyle(theme, 36).copyWith(
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${currentTask.duration} min',
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          )
                        : const Center(
                            child: Text(
                              'No current task',
                              style: TextStyle(
                                  fontSize: 24, color: Color(0xFF9CA3AF)),
                            ),
                          ),
                  ),
                ),

                // Transition indicator (flex 3)
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TransitionIndicator(
                        displaySettings: displaySettings,
                        theme: theme,
                        taskDuration: currentTask?.duration ?? 30,
                        elapsed: elapsedInTask,
                        isPast: false,
                        isActive: true,
                        width: MediaQuery.of(context).size.width * 0.4,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        '${((currentTask?.duration ?? 0) - elapsedInTask).clamp(0, double.infinity).floor()} Minute Remaining',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),

                // Next task (flex 1)
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: parseHexColor(theme.cardBgColor),
                      borderRadius: BorderRadius.circular(theme.borderRadius),
                      border: Border.all(
                        color: borderColor,
                        width: theme.borderWidthValue,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: nextTask != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'NEXT TASK',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (nextTask.icon != null)
                                Icon(
                                  getIconData(nextTask.icon),
                                  size: 64,
                                  color: borderColor,
                                ),
                              const SizedBox(height: 16),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  theme.fontTransform == 'uppercase'
                                      ? nextTask.content.toUpperCase()
                                      : nextTask.content,
                                  textAlign: TextAlign.center,
                                  style: getThemeTextStyle(theme, 28).copyWith(
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${nextTask.duration} min',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          )
                        : const Center(
                            child: Text(
                              'All done!',
                              style: TextStyle(
                                  fontSize: 20, color: Color(0xFF9CA3AF)),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Banner
        BannerBar(
          imageUrl: displaySettings.bottomBannerImage,
          height: displaySettings.bottomBannerHeight,
          theme: theme,
          isTop: false,
        ),
      ],
    );
  }
}
