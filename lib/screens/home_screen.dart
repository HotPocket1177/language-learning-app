import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';
import '../services/kuma_service.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';
import '../models/kuma_message.dart';
import '../widgets/kuma_mascot.dart';
import '../widgets/kuma_speech_bubble.dart' show BubbleTailDirection;
import 'vocabulary_screen.dart';
import 'sentences_screen.dart';
// TODO: Re-enable when AI conversations are ready
// import 'conversation_topics_screen.dart';
import 'mastered_gallery_screen.dart';
import 'practice_deck_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'review_screen.dart';
import 'stats_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<KumaMascotState> _kumaKey = GlobalKey();
  final KumaService _kumaService = KumaService();
  final AchievementService _achievementService = AchievementService();
  Timer? _messageTimer;
  String? _kumaBubbleText;
  KumaEmotion _kumaEmotion = KumaEmotion.idle;
  bool _showKumaBubble = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudyProvider>(context, listen: false).loadDueCounts();
      _initKuma();
      _achievementService.load();
    });
  }

  Future<void> _initKuma() async {
    await _kumaService.load();
    if (!mounted) return;
    _startMessageTimer();
  }

  void _startMessageTimer() {
    _messageTimer?.cancel();
    final interval = _kumaService.messageInterval;
    if (interval == Duration.zero || !_kumaService.showTips) return;

    _messageTimer = Timer.periodic(interval, (_) {
      if (!mounted) return;
      final msg = _kumaService.getRandomMessage();
      setState(() {
        _kumaBubbleText = msg.text;
        _kumaEmotion = msg.emotion;
        _showKumaBubble = true;
      });
    });
  }

  void _onKumaTap() {
    // Show a motivational message on tap
    final msg = _kumaService.getRandomMessage();
    setState(() {
      _kumaBubbleText = msg.text;
      _kumaEmotion = msg.emotion;
      _showKumaBubble = true;
    });
  }

  Future<void> _checkAchievements() async {
    if (!mounted) return;
    final provider = Provider.of<StudyProvider>(context, listen: false);
    final newlyUnlocked = await _achievementService.checkAchievements(provider);
    if (newlyUnlocked.isNotEmpty && mounted) {
      _showAchievementCelebration(newlyUnlocked);
    }
  }

  void _showAchievementCelebration(List<Achievement> achievements) {
    // Trigger Kuma celebrating
    setState(() {
      _kumaEmotion = KumaEmotion.celebrating;
      _kumaBubbleText = 'Congratulations! 🎉';
      _showKumaBubble = true;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 56, color: Color(0xFFFFD700)),
            const SizedBox(height: 12),
            Text(
              achievements.length == 1
                  ? 'Achievement Unlocked!'
                  : '${achievements.length} Achievements Unlocked!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.accent,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...achievements.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: a.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(a.icon, size: 24, color: a.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              a.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  void _showStudyModeSheet({
    required String title,
    required IconData icon,
    required int newCount,
    required int dueCount,
    required String itemType,
    required Widget studyNewScreen,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _StudyModeBottomSheet(
        title: title,
        icon: icon,
        newCount: newCount,
        dueCount: dueCount,
        itemType: itemType,
        studyNewScreen: studyNewScreen,
        onReturn: _checkAchievements,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyProvider>(
      builder: (context, provider, child) {
        final selectedLang = provider.selectedLanguage;
        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedLang != null) ...[
                  Text(selectedLang.flag),
                  const SizedBox(width: 8),
                ],
                Text('${selectedLang?.displayName ?? 'Language'} Study'),
              ],
            ),
            centerTitle: true,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'change_language') {
                    Navigator.of(context).pushReplacementNamed('/language-selector');
                  } else if (value == 'settings') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: context.accent),
                        const SizedBox(width: 8),
                        const Text('Settings'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'change_language',
                    child: Row(
                      children: [
                        Icon(Icons.language, color: context.accent),
                        const SizedBox(width: 8),
                        const Text('Change Language'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Consumer<StudyProvider>(
                  builder: (context, innerProvider, child) {
                    final stats = innerProvider.userStats;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Gradient hero — greeting + level ring + XP progress
                        _HeroHeader(
                          userName: stats.userName,
                          level: stats.level,
                          xpInLevel: stats.xp % stats.xpForNextLevel,
                          xpForNextLevel: stats.xpForNextLevel,
                        ),
                        const SizedBox(height: 16),

                        // Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.local_fire_department,
                                title: 'Day streak',
                                value: '${stats.currentStreak}',
                                color: context.coral,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.workspace_premium,
                                title: 'Mastered',
                                value: '${stats.totalWordsLearned + stats.totalSentencesLearned}',
                                color: const Color(0xFF6B9E64),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Study Sections
                        const _SectionHeader('Study', Icons.school),
                        const SizedBox(height: 12),

                        _StudyCard(
                          icon: Icons.book,
                          title: 'Vocabulary',
                          color: context.coral,
                          newCount: innerProvider.availableVocabulary.length,
                          dueCount: innerProvider.dueVocabularyCount,
                          onTap: () => _showStudyModeSheet(
                            title: 'Vocabulary',
                            icon: Icons.book,
                            newCount: innerProvider.availableVocabulary.length,
                            dueCount: innerProvider.dueVocabularyCount,
                            itemType: 'vocabulary',
                            studyNewScreen: const VocabularyScreen(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _StudyCard(
                          icon: Icons.chat_bubble,
                          title: 'Sentences',
                          color: const Color(0xFF4B93C4),
                          newCount: innerProvider.availableSentences.length,
                          dueCount: innerProvider.dueSentencesCount,
                          onTap: () => _showStudyModeSheet(
                            title: 'Sentences',
                            icon: Icons.chat_bubble,
                            newCount: innerProvider.availableSentences.length,
                            dueCount: innerProvider.dueSentencesCount,
                            itemType: 'sentence',
                            studyNewScreen: const SentencesScreen(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Progress Sections
                        const _SectionHeader('Your Progress', Icons.insights),
                        const SizedBox(height: 12),

                        _MenuButton(
                          icon: Icons.grid_view,
                          title: 'Mastered Gallery',
                          color: const Color(0xFF6B9E64),
                          subtitle:
                              '${stats.totalWordsLearned + stats.totalSentencesLearned} items mastered',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MasteredGalleryScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _MenuButton(
                          icon: Icons.fitness_center,
                          title: 'Practice Deck',
                          color: const Color(0xFFE8883A),
                          subtitle:
                              '${innerProvider.practiceVocabulary.length + innerProvider.practiceSentences.length} items to practice',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PracticeDeckScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _MenuButton(
                          icon: Icons.bar_chart,
                          title: 'Detailed Stats',
                          color: const Color(0xFF2FA8A0),
                          subtitle: 'Streaks, heatmap & progress',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const StatsScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _MenuButton(
                          icon: Icons.person,
                          title: 'Profile',
                          color: const Color(0xFF9B72CF),
                          subtitle: 'View your achievements',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ),

              // Kuma in top-right corner (60x60, idle with breathing)
              if (_kumaService.showKuma)
                Positioned(
                  top: 8,
                  right: 8,
                  child: KumaMascot(
                    key: _kumaKey,
                    emotion: _kumaEmotion,
                    size: 60,
                    showMessage: _showKumaBubble,
                    message: _kumaBubbleText,
                    bubbleTailDirection: BubbleTailDirection.right,
                    onTap: _onKumaTap,
                    onBubbleDismissed: () {
                      setState(() => _showKumaBubble = false);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Warm gradient hero at the top of Home: greeting, a circular level ring,
/// and the XP-to-next-level progress. The single biggest "pop" element.
class _HeroHeader extends StatelessWidget {
  final String userName;
  final int level;
  final int xpInLevel;
  final int xpForNextLevel;

  const _HeroHeader({
    required this.userName,
    required this.level,
    required this.xpInLevel,
    required this.xpForNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final progress = xpForNextLevel == 0 ? 0.0 : xpInLevel / xpForNextLevel;
    final remaining = xpForNextLevel - xpInLevel;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: context.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: BrandColors.coral.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$userName!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Level ring
              SizedBox(
                width: 62,
                height: 62,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 62,
                      height: 62,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 5,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$level',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          'LVL',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$remaining XP to Level ${level + 1}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header with a rounded accent "chip" icon — replaces the plain
/// text headers so each section reads as a distinct, lively block.
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: context.coral.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: context.coral),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.textSecondary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Study card that shows "X new | Y due" for each section
class _StudyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int newCount;
  final int dueCount;
  final Color color;
  final VoidCallback onTap;

  const _StudyCard({
    required this.icon,
    required this.title,
    required this.newCount,
    required this.dueCount,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.9),
                      color.withValues(alpha: 0.65),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: context.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _CountBadge(
                          count: newCount,
                          label: 'new',
                          color: color,
                        ),
                        const SizedBox(width: 8),
                        _CountBadge(
                          count: dueCount,
                          label: 'due',
                          color: dueCount > 0
                              ? context.coral
                              : Colors.grey.shade500,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: context.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small badge showing count + label (e.g. "5 new")
class _CountBadge extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _CountBadge({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}


class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: context.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: context.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet for selecting study mode
class _StudyModeBottomSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final int newCount;
  final int dueCount;
  final String itemType;
  final Widget studyNewScreen;
  final VoidCallback onReturn;

  const _StudyModeBottomSheet({
    required this.title,
    required this.icon,
    required this.newCount,
    required this.dueCount,
    required this.itemType,
    required this.studyNewScreen,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.track,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: context.accent, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Study New option
          _ModeOption(
            icon: Icons.add_circle_outline,
            title: 'Study New',
            subtitle: '$newCount items available',
            color: context.accent,
            enabled: newCount > 0,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => studyNewScreen),
              ).then((_) => onReturn());
            },
          ),
          const SizedBox(height: 12),

          // Review Due option
          _ModeOption(
            icon: Icons.replay,
            title: 'Review Due',
            subtitle: '$dueCount items due for review',
            color: Colors.orange.shade700,
            enabled: dueCount > 0,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewScreen(
                    itemType: itemType,
                    mode: StudyMode.reviewDue,
                    title: '$title Review',
                  ),
                ),
              ).then((_) => onReturn());
            },
          ),
          const SizedBox(height: 12),

          // Practice All option
          _ModeOption(
            icon: Icons.shuffle,
            title: 'Practice All',
            subtitle: 'Mix of new and review items',
            color: Colors.green.shade700,
            enabled: newCount > 0 || dueCount > 0,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewScreen(
                    itemType: itemType,
                    mode: StudyMode.practiceAll,
                    title: '$title Practice',
                  ),
                ),
              ).then((_) => onReturn());
            },
          ),
        ],
      ),
    );
  }
}

/// Single mode option in the bottom sheet
class _ModeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _ModeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
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
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: enabled ? color : context.textFaint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
