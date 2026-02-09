import 'package:flutter/material.dart';
import '../models/kuma_message.dart';
import 'kuma_mascot.dart';
import 'kuma_speech_bubble.dart' show BubbleTailDirection;

/// Kuma mascot positioned for the tutorial: larger, bottom-left, with a big speech bubble.
class KumaTutorial extends StatefulWidget {
  final KumaEmotion emotion;
  final String? message;
  final bool showMessage;
  final VoidCallback? onBubbleDismissed;

  const KumaTutorial({
    super.key,
    this.emotion = KumaEmotion.happy,
    this.message,
    this.showMessage = false,
    this.onBubbleDismissed,
  });

  @override
  State<KumaTutorial> createState() => _KumaTutorialState();
}

class _KumaTutorialState extends State<KumaTutorial>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bubbleMaxWidth = (screenWidth * 0.8).clamp(0.0, 300.0);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Kuma mascot (100x100)
            KumaMascot(
              emotion: widget.emotion,
              size: 100,
              showMessage: false, // We handle bubble separately
              bubbleTailDirection: BubbleTailDirection.bottom,
            ),
            const SizedBox(width: 8),
            // Large speech bubble next to Kuma
            if (widget.showMessage && widget.message != null)
              Flexible(
                child: _TutorialBubble(
                  message: widget.message!,
                  maxWidth: bubbleMaxWidth,
                  onDismissed: widget.onBubbleDismissed,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Larger speech bubble for tutorial - no auto-dismiss, stays until page changes.
class _TutorialBubble extends StatefulWidget {
  final String message;
  final double maxWidth;
  final VoidCallback? onDismissed;

  const _TutorialBubble({
    required this.message,
    required this.maxWidth,
    this.onDismissed,
  });

  @override
  State<_TutorialBubble> createState() => _TutorialBubbleState();
}

class _TutorialBubbleState extends State<_TutorialBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _TutorialBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: Alignment.bottomLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: widget.maxWidth),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5EBE0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF8b6f47),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8b6f47).withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            widget.message,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF4a4a4a),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
