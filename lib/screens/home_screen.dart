import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';
import 'vocabulary_screen.dart';
import 'sentences_screen.dart';
import 'kanji_screen.dart';
import 'mastered_gallery_screen.dart';
import 'practice_deck_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Japanese Study'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer<StudyProvider>(
          builder: (context, provider, child) {
            final stats = provider.userStats;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'ようこそ, ${stats.userName}!',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome back!',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.star,
                        title: 'Level',
                        value: '${stats.level}',
                        color: const Color(0xFF8b6f47),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department,
                        title: 'Streak',
                        value: '${stats.currentStreak}',
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // XP Progress Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Experience',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: const Color(0xFF8b6f47),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              '${stats.xp % stats.xpForNextLevel} / ${stats.xpForNextLevel} XP',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (stats.xp % stats.xpForNextLevel) / stats.xpForNextLevel,
                            minHeight: 20,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8b6f47)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${stats.xpForNextLevel - (stats.xp % stats.xpForNextLevel)} XP to Level ${stats.level + 1}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Study Sections
                Text(
                  'Study',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF8b6f47),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                _MenuButton(
                  icon: Icons.book,
                  title: 'Vocabulary',
                  subtitle: '${provider.availableVocabulary.length} words available',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VocabularyScreen()),
                  ),
                ),
                const SizedBox(height: 12),

                _MenuButton(
                  icon: Icons.chat_bubble,
                  title: 'Sentences',
                  subtitle: '${provider.availableSentences.length} sentences available',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SentencesScreen()),
                  ),
                ),
                const SizedBox(height: 12),

                _MenuButton(
                  icon: Icons.language,
                  title: 'Kanji Lessons',
                  subtitle: '${provider.availableKanji.length} kanji available',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const KanjiScreen()),
                  ),
                ),
                const SizedBox(height: 24),

                // Practice Sections
                Text(
                  'Your Progress',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF8b6f47),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                _MenuButton(
                  icon: Icons.grid_view,
                  title: 'Mastered Gallery',
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
                  subtitle:
                      '${provider.practiceVocabulary.length + provider.practiceSentences.length} items to practice',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PracticeDeckScreen()),
                  ),
                ),
                const SizedBox(height: 12),

                _MenuButton(
                  icon: Icons.person,
                  title: 'Profile',
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
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8b6f47).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF8b6f47), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8b6f47),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
