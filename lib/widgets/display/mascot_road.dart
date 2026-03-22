import 'package:flutter/material.dart';
import '../../data/transition_presets.dart';
import '../../utils/time_utils.dart';

class MascotRoad extends StatelessWidget {
  final int taskDuration;
  final double elapsed;
  final bool isPast;
  final bool isActive;
  final double roadWidth;
  final int roadHeight;
  final String spriteEmoji;
  final String selectedSurface;

  const MascotRoad({
    super.key,
    required this.taskDuration,
    required this.elapsed,
    required this.isPast,
    required this.isActive,
    required this.roadWidth,
    required this.roadHeight,
    required this.spriteEmoji,
    required this.selectedSurface,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        getProgressPercentage(isPast, isActive, elapsed, taskDuration) / 100;
    final surfaceColors = getSurfaceGradientColors(selectedSurface);
    final dashColor = getSurfaceDashColor(selectedSurface);

    return SizedBox(
      width: roadWidth,
      height: roadHeight.toDouble(),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Road surface
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: surfaceColors),
              borderRadius: BorderRadius.circular(roadHeight / 2),
            ),
          ),
          // Dashed center line
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                8,
                (_) => Container(
                  width: 12,
                  height: 2,
                  decoration: BoxDecoration(
                    color: dashColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
          // Sprite
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            left: (roadWidth * progress).clamp(4, roadWidth - 28),
            child: Text(
              spriteEmoji,
              style: TextStyle(fontSize: roadHeight * 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
