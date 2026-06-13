import 'package:flutter/material.dart';
import '../models/kuma_message.dart';
import '../services/kuma_service.dart';
import '../widgets/kuma_tutorial.dart';
import '../widgets/tutorial_overlay.dart';
import 'home_screen.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final KumaService _kumaService = KumaService();
  int _currentPage = 0;

  // Content fade/scale animation
  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<double> _contentScale;

  // Tutorial page definitions
  static const _pages = [
    _TutorialPageData(
      emotion: KumaEmotion.happy,
      message: "こんにちは! (Konnichiwa!)\nI'm Kuma-san! 🐻\nI'll be your study buddy!",
      buttonText: "Nice to meet you, Kuma-san!",
    ),
    _TutorialPageData(
      emotion: KumaEmotion.excited,
      message: "This shows your level and XP! ⭐\nStudy every day to level up!",
      buttonText: "Next",
    ),
    _TutorialPageData(
      emotion: KumaEmotion.encouraging,
      message: "Tap here to learn new words! 📚\nPractice sentences here! 💬\nMaster kanji characters! 漢字",
      buttonText: "Next",
    ),
    _TutorialPageData(
      emotion: KumaEmotion.celebrating,
      message: "Study every day for a streak! 🔥\nI'll remind you if you forget! 😊",
      buttonText: "Next",
    ),
    _TutorialPageData(
      emotion: KumaEmotion.happy,
      message: "After lessons, we can chat! 💭\nPractice real conversations with me!\nUnlock after 5 mastered items!",
      buttonText: "Next",
    ),
    _TutorialPageData(
      emotion: KumaEmotion.celebrating,
      message: "よし! (Yoshi!) Let's start!\nChoose a topic and let's go! 🚀",
      buttonText: "Start Learning!",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _contentScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
          parent: _contentController, curve: Curves.easeOutCubic),
    );
    _contentController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _pages.length) return;
    _contentController.reset();
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
    setState(() => _currentPage = page);
    _contentController.forward();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _goToPage(_currentPage + 1);
    } else {
      _completeTutorial();
    }
  }

  Future<void> _completeTutorial() async {
    await _kumaService.completeTutorial();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Welcome aboard! 🎉'),
        backgroundColor: Color(0xFF8b6f47),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSkipDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip tutorial?'),
        content: const Text(
          'You can replay it anytime from Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completeTutorial();
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C1810), Color(0xFF1A0F0A)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Page content
              PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  _contentController.reset();
                  setState(() => _currentPage = index);
                  _contentController.forward();
                },
                itemBuilder: (context, index) {
                  return _buildPage(index);
                },
              ),

              // Skip button (top right)
              Positioned(
                top: 8,
                right: 16,
                child: TextButton(
                  onPressed: _showSkipDialog,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              // Bottom: progress dots + button
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TutorialProgressDots(
                        totalPages: _pages.length,
                        currentPage: _currentPage,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8b6f47),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 6,
                            shadowColor:
                                const Color(0xFF8b6f47).withValues(alpha: 0.4),
                          ),
                          child: Text(
                            _pages[_currentPage].buttonText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
      child: Column(
        children: [
          const Spacer(flex: 1),
          // Illustrated content for this page
          FadeTransition(
            opacity: _contentFade,
            child: ScaleTransition(
              scale: _contentScale,
              child: _buildIllustration(index),
            ),
          ),
          const Spacer(flex: 1),
          // Kuma + speech bubble at bottom
          KumaTutorial(
            emotion: _pages[index].emotion,
            message: _pages[index].message,
            showMessage: true,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildIllustration(int index) {
    switch (index) {
      case 0:
        return _buildWelcomeIllustration();
      case 1:
        return _buildLevelIllustration();
      case 2:
        return _buildStudySectionsIllustration();
      case 3:
        return _buildStreakIllustration();
      case 4:
        return _buildConversationIllustration();
      case 5:
        return _buildReadyIllustration();
      default:
        return const SizedBox.shrink();
    }
  }

  // ---- Page illustrations ----

  Widget _buildWelcomeIllustration() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
              width: 3,
            ),
          ),
          child: const Center(
            child: Text('🐻', style: TextStyle(fontSize: 60)),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Welcome!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF5EBE0),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your Japanese learning adventure starts here',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFFF5EBE0).withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLevelIllustration() {
    return _MockCard(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.star, color: Theme.of(context).colorScheme.primary, size: 36),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Level 1',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 150,
                  height: 12,
                  child: LinearProgressIndicator(
                    value: 0.3,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF8b6f47)),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '30 / 100 XP',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudySectionsIllustration() {
    return Column(
      children: [
        _MockStudyCard(
          icon: Icons.book,
          title: 'Vocabulary',
          subtitle: '10 new | 5 due',
        ),
        const SizedBox(height: 10),
        _MockStudyCard(
          icon: Icons.chat_bubble,
          title: 'Sentences',
          subtitle: '8 new | 3 due',
        ),
        const SizedBox(height: 10),
        _MockStudyCard(
          icon: Icons.language,
          title: 'Kanji',
          subtitle: '15 new | 0 due',
        ),
      ],
    );
  }

  Widget _buildStreakIllustration() {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.5, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.5),
                width: 3,
              ),
            ),
            child: const Center(
              child: Text('🔥', style: TextStyle(fontSize: 50)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _MockCard(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department,
                  color: Colors.orange, size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '7 Day Streak',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    'Keep it going!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConversationIllustration() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('💭', style: TextStyle(fontSize: 40)),
          ),
        ),
        const SizedBox(height: 16),
        _MockCard(
          child: Column(
            children: [
              _ChatBubbleRow(
                text: 'こんにちは!',
                isKuma: true,
              ),
              const SizedBox(height: 8),
              _ChatBubbleRow(
                text: 'Hello, Kuma-san!',
                isKuma: false,
              ),
              const SizedBox(height: 8),
              _ChatBubbleRow(
                text: 'すごい! Great job! 🌟',
                isKuma: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadyIllustration() {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: const Text('🚀', style: TextStyle(fontSize: 80)),
        ),
        const SizedBox(height: 24),
        const Text(
          "You're all set!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF5EBE0),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Time to start your Japanese journey',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFFF5EBE0).withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ---- Helper widgets ----

class _TutorialPageData {
  final KumaEmotion emotion;
  final String message;
  final String buttonText;

  const _TutorialPageData({
    required this.emotion,
    required this.message,
    required this.buttonText,
  });
}

class _MockCard extends StatelessWidget {
  final Widget child;

  const _MockCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MockStudyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MockStudyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}

class _ChatBubbleRow extends StatelessWidget {
  final String text;
  final bool isKuma;

  const _ChatBubbleRow({required this.text, required this.isKuma});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isKuma ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (isKuma)
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Text('🐻', style: TextStyle(fontSize: 20)),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isKuma
                ? const Color(0xFF8b6f47).withValues(alpha: 0.1)
                : const Color(0xFF8b6f47).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isKuma ? const Color(0xFF4a4a4a) : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
