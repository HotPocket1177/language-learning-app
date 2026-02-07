import 'package:flutter/material.dart';

/// Direction the speech bubble tail points toward
enum BubbleTailDirection { left, right, bottom }

/// Reusable speech bubble with a tail pointing toward Kuma.
/// Warm beige fill (#f5ebe0), brown border (#8b6f47).
class SpeechBubble extends StatelessWidget {
  final String text;
  final VoidCallback? onDismiss;
  final BubbleTailDirection tailDirection;

  const SpeechBubble({
    super.key,
    required this.text,
    this.onDismiss,
    this.tailDirection = BubbleTailDirection.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: CustomPaint(
        painter: _BubblePainter(tailDirection: tailDirection),
        child: Container(
          padding: EdgeInsets.only(
            left: tailDirection == BubbleTailDirection.left ? 20 : 14,
            right: tailDirection == BubbleTailDirection.right ? 20 : 14,
            top: 10,
            bottom: tailDirection == BubbleTailDirection.bottom ? 18 : 10,
          ),
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF5a4528),
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
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
      ..strokeWidth = 1.5;

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
  bool shouldRepaint(covariant _BubblePainter old) => old.tailDirection != tailDirection;
}
