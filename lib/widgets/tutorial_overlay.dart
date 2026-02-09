import 'package:flutter/material.dart';

/// Dark overlay with an animated spotlight cutout for the tutorial.
class TutorialOverlay extends StatefulWidget {
  final Rect? highlightRect;
  final double borderRadius;
  final double overlayOpacity;
  final Widget child;

  const TutorialOverlay({
    super.key,
    this.highlightRect,
    this.borderRadius = 16,
    this.overlayOpacity = 0.85,
    required this.child,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark overlay with cutout
        if (widget.highlightRect != null)
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, _) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _SpotlightPainter(
                  highlightRect: widget.highlightRect!,
                  borderRadius: widget.borderRadius,
                  overlayOpacity: widget.overlayOpacity,
                  glowIntensity: _glowAnimation.value,
                ),
              );
            },
          )
        else
          Container(
            color: Colors.black.withValues(alpha: widget.overlayOpacity),
          ),
        // Content on top
        widget.child,
      ],
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect highlightRect;
  final double borderRadius;
  final double overlayOpacity;
  final double glowIntensity;

  _SpotlightPainter({
    required this.highlightRect,
    required this.borderRadius,
    required this.overlayOpacity,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dark overlay
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: overlayOpacity);

    // Create path with cutout
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutRRect = RRect.fromRectAndRadius(
      highlightRect,
      Radius.circular(borderRadius),
    );
    final cutoutPath = Path()..addRRect(cutoutRRect);

    // Subtract cutout from overlay
    final combinedPath =
        Path.combine(PathOperation.difference, overlayPath, cutoutPath);
    canvas.drawPath(combinedPath, overlayPaint);

    // Pulsing glow border around cutout
    final glowPaint = Paint()
      ..color = const Color(0xFF8b6f47)
          .withValues(alpha: 0.3 + (0.4 * glowIntensity))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 + (2 * glowIntensity)
      ..maskFilter =
          MaskFilter.blur(BlurStyle.normal, 8 + (6 * glowIntensity));
    canvas.drawRRect(cutoutRRect, glowPaint);

    // Inner sharp border
    final borderPaint = Paint()
      ..color =
          const Color(0xFF8b6f47).withValues(alpha: 0.6 + (0.3 * glowIntensity))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(cutoutRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.highlightRect != highlightRect;
  }
}

/// Progress dots for the tutorial pages.
class TutorialProgressDots extends StatelessWidget {
  final int totalPages;
  final int currentPage;

  const TutorialProgressDots({
    super.key,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF8b6f47)
                : const Color(0xFF8b6f47).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
