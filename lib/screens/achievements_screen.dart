import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../providers/study_provider.dart';
import '../services/achievement_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementService _achievementService = AchievementService();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _achievementService.load();
    if (mounted) setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : Consumer<StudyProvider>(
              builder: (context, provider, _) {
                final unlocked = _achievementService.unlockedCount;
                final total = AchievementService.allAchievements.length;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Summary card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                size: 48,
                                color: Color(0xFFFFD700),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '$unlocked / $total',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Achievements Unlocked',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: total > 0 ? unlocked / total : 0,
                                  minHeight: 10,
                                  backgroundColor: Colors.grey[300],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Color(0xFFFFD700)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Achievement categories
                      for (final category in AchievementCategory.values)
                        _buildCategory(context, category, provider),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildCategory(
      BuildContext context, AchievementCategory category, StudyProvider provider) {
    final achievements = AchievementService.allAchievements
        .where((a) => a.category == category)
        .toList();
    if (achievements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(category.icon, size: 20, color: const Color(0xFF8b6f47)),
            const SizedBox(width: 8),
            Text(
              category.displayName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            final unlocked = _achievementService.isUnlocked(achievement.id);
            return _AchievementCard(
              achievement: achievement,
              unlocked: unlocked,
              unlockedAt: _achievementService.unlockedAt(achievement.id),
              progress: _achievementService.getProgress(achievement.id, provider),
              progressText:
                  _achievementService.getProgressText(achievement.id, provider),
              onTap: () => _showDetail(context, achievement, unlocked),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showDetail(
      BuildContext context, Achievement achievement, bool unlocked) {
    final isHiddenLocked = achievement.isHidden && !unlocked;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: unlocked
                    ? achievement.color.withValues(alpha: 0.15)
                    : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isHiddenLocked ? Icons.help_outline : achievement.icon,
                size: 48,
                color: unlocked ? achievement.color : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isHiddenLocked ? '???' : achievement.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            if (!isHiddenLocked) ...[
              const SizedBox(height: 4),
              Text(
                achievement.titleJp,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              isHiddenLocked
                  ? 'Keep studying to discover this secret achievement!'
                  : achievement.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (unlocked) ...[
              const SizedBox(height: 12),
              Text(
                'Unlocked ${_formatDate(_achievementService.unlockedAt(achievement.id)!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;
  final DateTime? unlockedAt;
  final double progress;
  final String progressText;
  final VoidCallback onTap;

  const _AchievementCard({
    required this.achievement,
    required this.unlocked,
    this.unlockedAt,
    required this.progress,
    required this.progressText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isHiddenLocked = achievement.isHidden && !unlocked;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: unlocked
                      ? achievement.color.withValues(alpha: 0.15)
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isHiddenLocked ? Icons.help_outline : achievement.icon,
                  size: 32,
                  color: unlocked ? achievement.color : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isHiddenLocked ? '???' : achievement.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: unlocked ? const Color(0xFF8b6f47) : Colors.grey[500],
                ),
              ),
              const SizedBox(height: 4),
              if (!isHiddenLocked)
                Text(
                  achievement.titleJp,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: unlocked ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              const Spacer(),
              if (!unlocked && !isHiddenLocked && progressText.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                        achievement.color.withValues(alpha: 0.6)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  progressText,
                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
              ],
              if (unlocked)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: achievement.color),
                    const SizedBox(width: 4),
                    Text(
                      'Unlocked!',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: achievement.color,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
