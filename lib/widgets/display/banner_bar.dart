import 'package:flutter/material.dart';
import '../../models/theme_config.dart';
import '../../utils/theme_utils.dart';
import 'clock_widget.dart';

class BannerBar extends StatelessWidget {
  final String? imageUrl;
  final int height;
  final ThemeConfig theme;
  final bool showClock;
  final bool isTop;

  const BannerBar({
    super.key,
    this.imageUrl,
    required this.height,
    required this.theme,
    this.showClock = false,
    this.isTop = true,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null && !showClock) return const SizedBox.shrink();

    final color1 = parseHexColor(theme.cardBorderColor);
    final color2 = theme.cardBorderColorAlt != null
        ? parseHexColor(theme.cardBorderColorAlt!)
        : color1;

    return Container(
      height: height.toDouble(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isTop ? [color1, color2] : [color2, color1],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imageUrl != null)
            Image.network(
              imageUrl!,
              height: height.toDouble(),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          if (showClock) ...[
            if (imageUrl != null) const SizedBox(width: 32),
            const ClockWidget(
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
