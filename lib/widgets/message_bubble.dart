import 'package:flutter/material.dart';

/// Chat message bubble for the conversation screen.
class MessageBubble extends StatelessWidget {
  final String text;
  final String? romaji;
  final String? english;
  final bool isKuma;
  final bool showRomaji;
  final bool showTranslation;

  const MessageBubble({
    super.key,
    required this.text,
    this.romaji,
    this.english,
    required this.isKuma,
    this.showRomaji = false,
    this.showTranslation = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isKuma ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isKuma)
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/kuma.png',
                  width: 28,
                  height: 28,
                ),
              ),
            ),
          Container(
            constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isKuma
                  ? const Color(0xFF8b6f47)
                  : const Color(0xFFd4a574),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isKuma ? 4 : 16),
                bottomRight: Radius.circular(isKuma ? 16 : 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Primary text (Japanese)
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: isKuma ? Colors.white : const Color(0xFF3a2a1a),
                    height: 1.4,
                  ),
                ),
                // Romaji (if toggled on)
                if (showRomaji &&
                    romaji != null &&
                    romaji!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    romaji!,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isKuma
                          ? Colors.white.withValues(alpha: 0.7)
                          : const Color(0xFF3a2a1a).withValues(alpha: 0.6),
                    ),
                  ),
                ],
                // English translation (if toggled on)
                if (showTranslation &&
                    english != null &&
                    english!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    english!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isKuma
                          ? Colors.white.withValues(alpha: 0.6)
                          : const Color(0xFF3a2a1a).withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated typing indicator (3 bouncing dots).
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
    });
    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    // Stagger the animations
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/kuma.png',
                width: 28,
                height: 28,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _animations[i],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animations[i].value),
                      child: child,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
