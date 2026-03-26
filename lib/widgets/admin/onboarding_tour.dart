import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme_constants.dart';

const _kOnboardingKey = 'hasSeenOnboarding';

/// Check whether the user has already completed the onboarding tour.
Future<bool> hasSeenOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kOnboardingKey) ?? false;
}

/// Mark the onboarding tour as completed.
Future<void> markOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kOnboardingKey, true);
}

/// Reset the onboarding flag so the tour can be replayed.
Future<void> resetOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_kOnboardingKey);
}

/// A single step in the onboarding tour.
class TourStep {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final Alignment tooltipAlignment;

  const TourStep({
    required this.targetKey,
    required this.title,
    required this.description,
    this.tooltipAlignment = Alignment.bottomCenter,
  });
}

/// Displays a spotlight tour overlay that highlights UI elements one at a time.
class OnboardingTourOverlay extends StatefulWidget {
  final List<TourStep> steps;
  final VoidCallback onComplete;

  const OnboardingTourOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
  });

  @override
  State<OnboardingTourOverlay> createState() => _OnboardingTourOverlayState();
}

class _OnboardingTourOverlayState extends State<OnboardingTourOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < widget.steps.length - 1) {
      _animController.reverse().then((_) {
        setState(() => _currentStep++);
        _animController.forward();
      });
    } else {
      _finish();
    }
  }

  void _previous() {
    if (_currentStep > 0) {
      _animController.reverse().then((_) {
        setState(() => _currentStep--);
        _animController.forward();
      });
    }
  }

  void _finish() async {
    await markOnboardingComplete();
    widget.onComplete();
  }

  Rect? _getTargetRect() {
    final key = widget.steps[_currentStep].targetKey;
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final offset = renderObject.localToGlobal(Offset.zero);
      return Rect.fromLTWH(
        offset.dx,
        offset.dy,
        renderObject.size.width,
        renderObject.size.height,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStep];
    final targetRect = _getTargetRect();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dark overlay with spotlight cutout
          Positioned.fill(
            child: CustomPaint(
              painter: _SpotlightPainter(
                targetRect: targetRect,
                overlayColor: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ),

          // Tap anywhere on overlay to advance (except tooltip area)
          Positioned.fill(
            child: GestureDetector(
              onTap: _next,
              behavior: HitTestBehavior.translucent,
            ),
          ),

          // Tooltip
          if (targetRect != null)
            _buildTooltip(context, step, targetRect),
        ],
      ),
    );
  }

  Widget _buildTooltip(BuildContext context, TourStep step, Rect targetRect) {
    final screenSize = MediaQuery.of(context).size;
    const tooltipWidth = 340.0;
    const padding = 16.0;

    // Determine if tooltip should go above or below the target
    final spaceBelow = screenSize.height - targetRect.bottom;
    final spaceAbove = targetRect.top;
    final showBelow = spaceBelow > 200 || spaceBelow > spaceAbove;

    // Horizontal positioning: centre on target, clamped to screen
    double left = targetRect.center.dx - tooltipWidth / 2;
    left = left.clamp(padding, screenSize.width - tooltipWidth - padding);

    final top = showBelow
        ? targetRect.bottom + 12
        : targetRect.top - 12; // will use bottom alignment

    return Positioned(
      left: left,
      top: showBelow ? top : null,
      bottom: showBelow ? null : screenSize.height - top,
      width: tooltipWidth,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step counter
                Text(
                  'Step ${_currentStep + 1} of ${widget.steps.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandText,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip / Back
                    if (_currentStep == 0)
                      TextButton(
                        onPressed: _finish,
                        child: Text(
                          'Skip tour',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: _previous,
                        child: const Text('Back'),
                      ),

                    // Next / Finish
                    ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        _currentStep == widget.steps.length - 1
                            ? 'Get started'
                            : 'Next',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter that draws a semi-transparent overlay with a rounded
/// rectangular cutout around the target widget.
class _SpotlightPainter extends CustomPainter {
  final Rect? targetRect;
  final Color overlayColor;

  _SpotlightPainter({
    required this.targetRect,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    if (targetRect == null) {
      canvas.drawRect(fullRect, paint);
      return;
    }

    // Expand the cutout slightly for visual breathing room
    final spotlight = targetRect!.inflate(8);

    final path = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(spotlight, const Radius.circular(8)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw a subtle border around the spotlight
    final borderPaint = Paint()
      ..color = AppColors.brandPrimary.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(spotlight, const Radius.circular(8)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect;
  }
}
