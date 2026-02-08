import 'dart:async';
import 'package:flutter/material.dart';

/// Direction the speech bubble tail points toward
enum BubbleTailDirection { left, right, bottom }

/// Speech bubble with fade in/out animation and auto-dismiss.
///
/// - Rounded rectangle with tail pointing to Kuma
/// - Background: #f5ebe0 (beige), Border: #8b6f47 (brown), 2px
/// - Padding: 12px, Max width: 200px
/// - Auto-dismiss after 4 seconds
/// - Fade in/out animation
class KumaSpeechBubble extends StatefulWidget {
  final String text;
  final BubbleTailDirection tailDirection;
  final VoidCallback? onDismissed;
  final Duration autoDismissAfter;

  const KumaSpeechBubble({
    super.key,
    required this.text,
    this.tailDirection = BubbleTailDirection.bottom,
    this.onDismissed,
    this.autoDismissAfter = const Duration(seconds: 4),
  });

  @override
  State<KumaSpeechBubble> createState() => _KumaSpeechBubbleState();
}

class _KumaSpeechBubbleState extends State<KumaSpeechBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Fade in
    _fadeController.forward();

    // Start auto-dismiss timer
    _startDismissTimer();
  }

  @override
  void didUpdateWidget(KumaSpeechBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      // New message: reset fade and timer
      _fadeController.forward(from: 0);
      _dismissTimer?.cancel();
      _startDismissTimer();
    }
  }

  void _startDismissTimer() {
    _dismissTimer?.cancel();
    _dismissTimer = Timer(widget.autoDismissAfter, _dismiss);
  }

  void _dismiss() async {
    if (!mounted) return;
    await _fadeController.reverse();
    if (mounted) {
      widget.onDismissed?.call();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _dismiss,
        child: CustomPaint(
          painter: _BubblePainter(tailDirection: widget.tailDirection),
          child: Container(
            padding: EdgeInsets.only(
              left: widget.tailDirection == BubbleTailDirection.left ? 20 : 12,
              right: widget.tailDirection == BubbleTailDirection.right ? 20 : 12,
              top: 12,
              bottom: widget.tailDirection == BubbleTailDirection.bottom ? 20 : 12,
            ),
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              widget.text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5a4528),
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final BubbleTailDirection tailDirection;

  _BubblePainter({required this.tailDirection});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = const Color(0xFFF5EBE0)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF8b6f47)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const radius = 12.0;
    const tailSize = 8.0;

    late final RRect bubbleRect;
    late final Path tailPath;

    switch (tailDirection) {
      case BubbleTailDirection.bottom:
        bubbleRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height - tailSize),
          const Radius.circular(radius),
        );
        tailPath = Path()
          ..moveTo(size.width / 2 - 6, size.height - tailSize)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(size.width / 2 + 6, size.height - tailSize);
        break;
      case BubbleTailDirection.left:
        bubbleRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(tailSize, 0, size.width - tailSize, size.height),
          const Radius.circular(radius),
        );
        tailPath = Path()
          ..moveTo(tailSize, size.height / 2 - 6)
          ..lineTo(0, size.height / 2)
          ..lineTo(tailSize, size.height / 2 + 6);
        break;
      case BubbleTailDirection.right:
        bubbleRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width - tailSize, size.height),
          const Radius.circular(radius),
        );
        tailPath = Path()
          ..moveTo(size.width - tailSize, size.height / 2 - 6)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(size.width - tailSize, size.height / 2 + 6);
        break;
    }

    // Draw fill
    canvas.drawRRect(bubbleRect, fillPaint);
    canvas.drawPath(tailPath, fillPaint);

    // Draw border
    canvas.drawRRect(bubbleRect, borderPaint);
    canvas.drawPath(tailPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) =>
      old.tailDirection != tailDirection;
}
