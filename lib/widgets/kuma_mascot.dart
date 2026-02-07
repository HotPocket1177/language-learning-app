import 'dart:async';
import 'package:flutter/material.dart';
import '../models/kuma_message.dart';
import '../services/kuma_service.dart';
import 'speech_bubble.dart';

/// Kuma mascot widget with mood-based animations and optional speech bubble.
///
/// Sizes:
///   [KumaMascotSize.small]  – 50x50  (home screen corner)
///   [KumaMascotSize.medium] – 70x70  (review screen corner)
///   [KumaMascotSize.large]  – 120x120 (welcome screen hero)
enum KumaMascotSize { small, medium, large }

class KumaMascot extends StatefulWidget {
  final KumaMascotSize size;
  final KumaMood initialMood;
  final VoidCallback? onTap;

  /// If non-null, the bubble text is shown immediately.
  final String? bubbleText;

  /// Direction of the speech bubble tail
  final BubbleTailDirection bubbleTailDirection;

  /// Whether to auto-dismiss the bubble after 5 s
  final bool autoDismissBubble;

  /// Called when the bubble is dismissed
  final VoidCallback? onBubbleDismissed;

  const KumaMascot({
    super.key,
    this.size = KumaMascotSize.medium,
    this.initialMood = KumaMood.idle,
    this.onTap,
    this.bubbleText,
    this.bubbleTailDirection = BubbleTailDirection.bottom,
    this.autoDismissBubble = true,
    this.onBubbleDismissed,
  });

  @override
  State<KumaMascot> createState() => KumaMascotState();
}

class KumaMascotState extends State<KumaMascot> with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _bounceController;
  late AnimationController _shakeController;

  late Animation<double> _idleAnimation; // subtle breathing
  late Animation<double> _bounceAnimation; // happy / celebrate
  late Animation<double> _shakeAnimation; // wave / sad

  KumaMood _mood = KumaMood.idle;
  String? _currentBubbleText;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _mood = widget.initialMood;
    _currentBubbleText = widget.bubbleText;

    // Idle breathing
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _idleAnimation = Tween<double>(begin: 0, end: 3).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    // Bounce
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeOut));

    // Shake (wave / sad)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 3.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 3.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    _playMoodAnimation();
    _startDismissTimer();
  }

  @override
  void didUpdateWidget(KumaMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMood != oldWidget.initialMood) {
      setMood(widget.initialMood);
    }
    if (widget.bubbleText != oldWidget.bubbleText) {
      _dismissTimer?.cancel();
      setState(() => _currentBubbleText = widget.bubbleText);
      _startDismissTimer();
    }
  }

  void _startDismissTimer() {
    if (_currentBubbleText != null && widget.autoDismissBubble) {
      _dismissTimer?.cancel();
      _dismissTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() => _currentBubbleText = null);
          widget.onBubbleDismissed?.call();
        }
      });
    }
  }

  /// Public: trigger a mood + optional bubble from parent
  void setMood(KumaMood mood, {String? bubbleText}) {
    setState(() {
      _mood = mood;
      if (bubbleText != null) _currentBubbleText = bubbleText;
    });
    _playMoodAnimation();
    if (bubbleText != null) _startDismissTimer();
  }

  /// Public: show a KumaMessage
  void showMessage(KumaMessage message) {
    setMood(message.mood, bubbleText: message.text);
  }

  void _playMoodAnimation() {
    switch (_mood) {
      case KumaMood.happy:
      case KumaMood.celebrate:
        _bounceController.forward(from: 0);
        break;
      case KumaMood.wave:
      case KumaMood.sad:
        _shakeController.forward(from: 0);
        break;
      case KumaMood.idle:
        break;
    }
  }

  double get _px {
    switch (widget.size) {
      case KumaMascotSize.small:
        return 50;
      case KumaMascotSize.medium:
        return 70;
      case KumaMascotSize.large:
        return 120;
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _bounceController.dispose();
    _shakeController.dispose();
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kumaService = KumaService();
    if (!kumaService.showKuma) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Speech bubble (above Kuma)
        if (_currentBubbleText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SpeechBubble(
              text: _currentBubbleText!,
              tailDirection: widget.bubbleTailDirection,
              onDismiss: () {
                _dismissTimer?.cancel();
                setState(() => _currentBubbleText = null);
                widget.onBubbleDismissed?.call();
              },
            ),
          ),

        // Kuma image
        GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: Listenable.merge([_idleAnimation, _bounceAnimation, _shakeAnimation]),
            builder: (context, child) {
              final dy = _idleAnimation.value +
                  (_bounceController.isAnimating ? _bounceAnimation.value : 0.0);
              final dx = _shakeController.isAnimating ? _shakeAnimation.value : 0.0;
              final double angle = _mood == KumaMood.celebrate && _bounceController.isAnimating
                  ? _bounceAnimation.value * 0.02
                  : 0.0;

              return Transform.translate(
                offset: Offset(dx, dy),
                child: Transform.rotate(
                  angle: angle,
                  child: child,
                ),
              );
            },
            child: Opacity(
              opacity: _mood == KumaMood.sad ? 0.75 : 1.0,
              child: Image.asset(
                'assets/images/kuma.png',
                width: _px,
                height: _px,
                filterQuality: FilterQuality.none, // keep pixel art crisp
              ),
            ),
          ),
        ),
      ],
    );
  }
}
