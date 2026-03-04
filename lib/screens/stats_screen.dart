import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detailed Stats')),
      body: Consumer<StudyProvider>(
        builder: (context, provider, _) {
          final stats = provider.userStats;
          final content = provider.currentLanguageContent;
          final totalVocab = content?.vocabulary.length ?? 0;
          final totalSentences = content?.sentences.length ?? 0;
          final totalKanji = content?.specialContent?.length ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Streak calendar heatmap
                _SectionHeader(title: 'Study Activity', icon: Icons.calendar_today),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _StudyHeatmap(studyDates: provider.studyDates),
                  ),
                ),
                const SizedBox(height: 20),

                // Summary stats
                _SectionHeader(title: 'Overview', icon: Icons.bar_chart),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _SummaryRow(
                          icon: Icons.calendar_month,
                          label: 'Days since starting',
                          value: _daysSinceStart(provider.studyDates),
                          color: const Color(0xFF8b6f47),
                        ),
                        const Divider(height: 24),
                        _SummaryRow(
                          icon: Icons.event_available,
                          label: 'Total study sessions',
                          value: '${provider.studyDates.length}',
                          color: Colors.blue,
                        ),
                        const Divider(height: 24),
                        _SummaryRow(
                          icon: Icons.local_fire_department,
                          label: 'Current streak',
                          value: '${stats.currentStreak} days',
                          color: Colors.orange,
                        ),
                        const Divider(height: 24),
                        _SummaryRow(
                          icon: Icons.emoji_events,
                          label: 'Longest streak',
                          value: '${stats.longestStreak} days',
                          color: const Color(0xFFFFD700),
                        ),
                        const Divider(height: 24),
                        _SummaryRow(
                          icon: Icons.trending_up,
                          label: 'Total XP earned',
                          value: '${stats.xp}',
                          color: Colors.purple,
                        ),
                        const Divider(height: 24),
                        _SummaryRow(
                          icon: Icons.star,
                          label: 'Current level',
                          value: '${stats.level}',
                          color: const Color(0xFF8b6f47),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Learning progress
                _SectionHeader(title: 'Learning Progress', icon: Icons.school),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _ProgressBar(
                          label: 'Vocabulary',
                          current: stats.totalWordsLearned,
                          total: totalVocab,
                          color: Colors.blue,
                          icon: Icons.book,
                        ),
                        const SizedBox(height: 16),
                        _ProgressBar(
                          label: 'Sentences',
                          current: stats.totalSentencesLearned,
                          total: totalSentences,
                          color: Colors.green,
                          icon: Icons.chat_bubble,
                        ),
                        if (provider.hasSpecialContent) ...[
                          const SizedBox(height: 16),
                          _ProgressBar(
                            label: 'Kanji',
                            current: stats.totalKanjiLearned,
                            total: totalKanji,
                            color: Colors.red,
                            icon: Icons.language,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Category breakdown
                _SectionHeader(
                    title: 'Category Breakdown', icon: Icons.pie_chart),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _CategoryBreakdown(provider: provider),
                  ),
                ),
                const SizedBox(height: 20),

                // Personal bests
                _SectionHeader(
                    title: 'Personal Bests', icon: Icons.workspace_premium),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _SummaryRow(
                          icon: Icons.local_fire_department,
                          label: 'Best streak',
                          value: '${stats.longestStreak} days',
                          color: Colors.orange,
                        ),
                        const Divider(height: 24),
                        _SummaryRow(
                          icon: Icons.verified,
                          label: 'Best correct streak',
                          value: '${stats.bestConsecutiveCorrect} in a row',
                          color: Colors.blue,
                        ),
                        const Divider(height: 24),
                        _SummaryRow(
                          icon: Icons.star,
                          label: 'Highest level',
                          value: '${stats.level}',
                          color: const Color(0xFFFFD700),
                        ),
                        const Divider(height: 24),
                        _SummaryRow(
                          icon: Icons.translate,
                          label: 'Languages studied',
                          value: '${provider.studiedLanguageCount}',
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  String _daysSinceStart(List<String> studyDates) {
    if (studyDates.isEmpty) return '0';
    final dates = studyDates.map((s) => DateTime.parse(s)).toList()..sort();
    return '${DateTime.now().difference(dates.first).inDays}';
  }
}

// ── Section header ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF8b6f47)),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8b6f47),
              ),
        ),
      ],
    );
  }
}

// ── Summary row ────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}

// ── Progress bar with label ────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final String label;
  final int current;
  final int total;
  final Color color;
  final IconData icon;

  const _ProgressBar({
    required this.label,
    required this.current,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? current / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '$current / $total',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 12,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(pct * 100).toStringAsFixed(0)}% complete',
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }
}

// ── Category breakdown ─────────────────────────────────────────

class _CategoryBreakdown extends StatelessWidget {
  final StudyProvider provider;

  const _CategoryBreakdown({required this.provider});

  @override
  Widget build(BuildContext context) {
    // Count mastered items per category
    final categoryCounts = <String, int>{};
    for (final item in provider.masteredVocabulary) {
      categoryCounts[item.category] =
          (categoryCounts[item.category] ?? 0) + 1;
    }
    for (final item in provider.masteredSentences) {
      categoryCounts[item.category] =
          (categoryCounts[item.category] ?? 0) + 1;
    }

    if (categoryCounts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Start studying to see your category breakdown!',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final sorted = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = sorted.first.value;

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return Column(
      children: sorted.asMap().entries.map((entry) {
        final i = entry.key;
        final cat = entry.value;
        final color = colors[i % colors.length];
        final pct = maxCount > 0 ? cat.value / maxCount : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  cat.key,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 16,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text(
                  '${cat.value}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── GitHub-style heatmap calendar ──────────────────────────────

class _StudyHeatmap extends StatelessWidget {
  final List<String> studyDates;

  const _StudyHeatmap({required this.studyDates});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    // Show last 13 weeks (91 days)
    final startDate = today.subtract(const Duration(days: 90));
    // Align to start of week (Monday)
    final alignedStart =
        startDate.subtract(Duration(days: startDate.weekday - 1));

    final dateSet = studyDates.toSet();
    final totalDays = today.difference(alignedStart).inDays + 1;
    final weeks = (totalDays / 7).ceil();

    final dayLabels = ['M', '', 'W', '', 'F', '', 'S'];
    final monthLabels = <int, String>{};

    // Calculate month labels for the top row
    for (int w = 0; w < weeks; w++) {
      final date = alignedStart.add(Duration(days: w * 7));
      if (date.day <= 7) {
        monthLabels[w] = _monthName(date.month);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month labels
        Row(
          children: [
            const SizedBox(width: 20), // offset for day labels
            Expanded(
              child: SizedBox(
                height: 16,
                child: CustomPaint(
                  painter: _MonthLabelPainter(
                    monthLabels: monthLabels,
                    weeks: weeks,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels
            Column(
              children: List.generate(7, (i) {
                return SizedBox(
                  height: 14,
                  width: 16,
                  child: Text(
                    dayLabels[i],
                    style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                  ),
                );
              }),
            ),
            const SizedBox(width: 4),
            // Heatmap grid
            Expanded(
              child: SizedBox(
                height: 7 * 14.0,
                child: CustomPaint(
                  painter: _HeatmapPainter(
                    startDate: alignedStart,
                    today: today,
                    studyDates: dateSet,
                    weeks: weeks,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Less', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            const SizedBox(width: 4),
            _legendBox(Colors.grey[200]!),
            _legendBox(const Color(0xFFC8E6C9)),
            _legendBox(const Color(0xFF81C784)),
            _legendBox(const Color(0xFF4CAF50)),
            _legendBox(const Color(0xFF2E7D32)),
            const SizedBox(width: 4),
            Text('More', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          ],
        ),
      ],
    );
  }

  Widget _legendBox(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month - 1];
  }
}

class _MonthLabelPainter extends CustomPainter {
  final Map<int, String> monthLabels;
  final int weeks;

  _MonthLabelPainter({required this.monthLabels, required this.weeks});

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / weeks;
    final textStyle = TextStyle(fontSize: 10, color: Colors.grey[500]);

    for (final entry in monthLabels.entries) {
      final tp = TextPainter(
        text: TextSpan(text: entry.value, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(entry.key * cellWidth, 0));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeatmapPainter extends CustomPainter {
  final DateTime startDate;
  final DateTime today;
  final Set<String> studyDates;
  final int weeks;

  _HeatmapPainter({
    required this.startDate,
    required this.today,
    required this.studyDates,
    required this.weeks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / weeks;
    const cellH = 14.0;
    const radius = 2.0;

    for (int w = 0; w < weeks; w++) {
      for (int d = 0; d < 7; d++) {
        final date = startDate.add(Duration(days: w * 7 + d));
        if (date.isAfter(today)) continue;

        final dateStr = date.toIso8601String().substring(0, 10);
        final studied = studyDates.contains(dateStr);

        final color = studied ? const Color(0xFF4CAF50) : Colors.grey[200]!;

        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * cellW + 1, d * cellH + 1, cellW - 2, cellH - 2),
          const Radius.circular(radius),
        );
        canvas.drawRRect(rect, Paint()..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
