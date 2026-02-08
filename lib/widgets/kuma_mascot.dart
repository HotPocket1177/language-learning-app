import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/kuma_message.dart';
import '../services/kuma_service.dart';
import 'kuma_speech_bubble.dart';

/// Kuma mascot widget with emotion-based animations and optional speech bubble.
///
/// Emotion states and their animations:
///   [KumaEmotion.idle]         – subtle breathing (scale 1.0 ↔ 1.02, 2s loop)
///   [KumaEmotion.happy]        – bounce (up/down 10px, 0.5s)
///   [KumaEmotion.excited]      – jump (up 20px, faster bounce)
///   [KumaEmotion.celebrating]  – spin 360° + scale pulse
///   [KumaEmotion.encouraging]  – gentle nod (rotate ±5°)
///   [KumaEmotion.sad]          – slow droop (opacity 0.7, move down 5px)
class KumaMascot extends StatefulWidget {
  final KumaEmotion emotion;
  final double size;
  final bool showMessage;
  final String? message;
  final VoidCallback? onTap;
  final BubbleTailDirection bubbleTailDirection;
  final VoidCallback? onBubbleDismissed;

  const KumaMascot({
    super.key,
    this.emotion = KumaEmotion.idle,
    this.size = 80.0,
    this.showMessage = false,
    this.message,
    this.onTap,
    this.bubbleTailDirection = BubbleTailDirection.bottom,
    this.onBubbleDismissed,
  });

  @override
  State<KumaMascot> createState() => KumaMascotState();
}

class KumaMascotState extends State<KumaMascot> with TickerProviderStateMixin {
  // Idle: breathing animation (scale 1.0 ↔ 1.02, 2s loop)
  late AnimationController _idleController;
  late Animation<double> _idleScaleAnimation;

  // Happy: bounce (up/down 10px, 0.5s)
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // Excited: jump (up 20px, faster bounce)
  late AnimationController _jumpController;
  late Animation<double> _jumpAnimation;

  // Celebrating: spin 360° + scale pulse
  late AnimationController _celebrateController;
  late Animation<double> _spinAnimation;
  late Animation<double> _pulseAnimation;

  // Encouraging: gentle nod (rotate ±5°)
  late AnimationController _nodController;
  late Animation<double> _nodAnimation;

  // Sad: slow droop (move down 5px)
  late AnimationController _droopController;
  late Animation<double> _droopAnimation;

  KumaEmotion _currentEmotion = KumaEmotion.idle;
  String? _currentMessage;
  bool _showBubble = false;

  @override
  void initState() {
    super.initState();
    _currentEmotion = widget.emotion;
    _currentMessage = widget.message;
    _showBubble = widget.showMessage && widget.message != null;

    _initAnimations();
    _playEmotionAnimation();
  }

  void _initAnimations() {
    // Idle: breathing scale
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _idleScaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    // Happy: bounce up/down 10px
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));

    // Excited: jump up 20px, faster
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _jumpAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -20.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -20.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _jumpController, curve: Curves.easeOut));

    // Celebrating: spin 360° + scale pulse
    _celebrateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _spinAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _celebrateController, curve: Curves.easeInOut),
    );
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _celebrateController, curve: Curves.easeInOut));

    // Encouraging: gentle nod ±5°
    _nodController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _nodAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 5.0 * math.pi / 180),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 5.0 * math.pi / 180, end: -5.0 * math.pi / 180),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -5.0 * math.pi / 180, end: 0.0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(parent: _nodController, curve: Curves.easeInOut));

    // Sad: droop down 5px
    _droopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _droopAnimation = Tween<double>(begin: 0.0, end: 5.0).animate(
      CurvedAnimation(parent: _droopController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(KumaMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.emotion != oldWidget.emotion) {
      setEmotion(widget.emotion);
    }
    if (widget.message != oldWidget.message || widget.showMessage != oldWidget.showMessage) {
      setState(() {
        _currentMessage = widget.message;
        _showBubble = widget.showMessage && widget.message != null;
      });
    }
  }

  /// Public: trigger an emotion + optional message from parent
  void setEmotion(KumaEmotion emotion, {String? message}) {
    setState(() {
      _currentEmotion = emotion;
      if (message != null) {
        _currentMessage = message;
        _showBubble = true;
      }
    });
    _playEmotionAnimation();
  }

  /// Public: show a KumaMessage
  void showMessage(KumaMessage msg) {
    setEmotion(msg.emotion, message: msg.text);
  }

  void _playEmotionAnimation() {
    // Reset all non-idle controllers
    _bounceController.reset();
    _jumpController.reset();
    _celebrateController.reset();
    _nodController.reset();
    _droopController.reset();

    switch (_currentEmotion) {
      case KumaEmotion.happy:
        _bounceController.forward(from: 0);
        break;
      case KumaEmotion.excited:
        _jumpController.forward(from: 0);
        break;
      case KumaEmotion.celebrating:
        _celebrateController.forward(from: 0);
        break;
      case KumaEmotion.encouraging:
        _nodController.forward(from: 0);
        break;
      case KumaEmotion.sad:
        _droopController.forward(from: 0);
        break;
      case KumaEmotion.idle:
        break; // idle breathing runs continuously
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _bounceController.dispose();
    _jumpController.dispose();
    _celebrateController.dispose();
    _nodController.dispose();
    _droopController.dispose();
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
        if (_showBubble && _currentMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: KumaSpeechBubble(
              text: _currentMessage!,
              tailDirection: widget.bubbleTailDirection,
              onDismissed: () {
                setState(() => _showBubble = false);
                widget.onBubbleDismissed?.call();
              },
            ),
          ),

        // Kuma image with animations
        GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _idleScaleAnimation,
              _bounceAnimation,
              _jumpAnimation,
              _spinAnimation,
              _pulseAnimation,
              _nodAnimation,
              _droopAnimation,
            ]),
            builder: (context, child) {
              // Calculate transforms based on current emotion
              double translateY = 0.0;
              double rotation = 0.0;
              double scale = _idleScaleAnimation.value;
              double opacity = 1.0;

              switch (_currentEmotion) {
                case KumaEmotion.happy:
                  if (_bounceController.isAnimating) {
                    translateY = _bounceAnimation.value;
                  }
                  break;
                case KumaEmotion.excited:
                  if (_jumpController.isAnimating) {
                    translateY = _jumpAnimation.value;
                  }
                  break;
                case KumaEmotion.celebrating:
                  if (_celebrateController.isAnimating) {
                    rotation = _spinAnimation.value;
                    scale = _pulseAnimation.value;
                  }
                  break;
                case KumaEmotion.encouraging:
                  if (_nodController.isAnimating) {
                    rotation = _nodAnimation.value;
                  }
                  break;
                case KumaEmotion.sad:
                  opacity = 0.7;
                  if (_droopController.isAnimating) {
                    translateY = _droopAnimation.value;
                  } else if (_droopController.isCompleted) {
                    translateY = 5.0;
                  }
                  break;
                case KumaEmotion.idle:
                  break;
              }

              return Transform.translate(
                offset: Offset(0, translateY),
                child: Transform.rotate(
                  angle: rotation,
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: child,
                    ),
                  ),
                ),
              );
            },
            child: Image.asset(
              'assets/images/kuma.png',
              width: widget.size,
              height: widget.size,
              filterQuality: FilterQuality.none, // keep pixel art crisp
            ),
          ),
        ),
      ],
    );
  }
}
