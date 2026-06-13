import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';
import '../models/kanji_item.dart';

class KanjiScreen extends StatefulWidget {
  const KanjiScreen({super.key});

  @override
  State<KanjiScreen> createState() => _KanjiScreenState();
}

class _KanjiScreenState extends State<KanjiScreen> {
  int currentIndex = 0;
  bool showDetails = false;

  void _masterKanji(BuildContext context, KanjiItem kanji) {
    final provider = Provider.of<StudyProvider>(context, listen: false);
    provider.masterKanji(kanji.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Kanji mastered! +10 XP'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );

    final availableKanji = provider.availableKanji;
    if (availableKanji.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All kanji mastered!'),
          backgroundColor: Color(0xFF8b6f47),
        ),
      );
    } else {
      setState(() {
        currentIndex = 0;
        showDetails = false;
      });
    }
  }

  void _nextKanji(List<KanjiItem> kanjiList) {
    if (currentIndex < kanjiList.length - 1) {
      setState(() {
        currentIndex++;
        showDetails = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No more kanji available'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanji Lessons'),
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          final kanjiList = provider.availableKanji;

          if (kanjiList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All kanji mastered!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Great job!',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          if (currentIndex >= kanjiList.length) {
            currentIndex = 0;
          }

          final kanji = kanjiList[currentIndex];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Progress Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${currentIndex + 1} / ${kanjiList.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Stroke Count: ${kanji.strokeCount}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF8b6f47),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Kanji Card
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showDetails = !showDetails;
                      });
                    },
                    child: Card(
                      elevation: 8,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!showDetails) ...[
                                Text(
                                  kanji.kanji,
                                  style: const TextStyle(
                                    fontSize: 120,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  kanji.meaning,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: const Color(0xFF8b6f47),
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ] else ...[
                                Text(
                                  kanji.kanji,
                                  style: const TextStyle(
                                    fontSize: 80,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  kanji.meaning,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: const Color(0xFF8b6f47),
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                _DetailRow(
                                  label: 'On\'yomi (音読み)',
                                  value: kanji.onyomi,
                                ),
                                const SizedBox(height: 16),
                                _DetailRow(
                                  label: 'Kun\'yomi (訓読み)',
                                  value: kanji.kunyomi,
                                ),
                                const SizedBox(height: 24),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Examples:',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF8b6f47),
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...kanji.examples.map((example) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '• $example',
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                      ),
                                    )),
                              ],
                              const SizedBox(height: 32),
                              Text(
                                showDetails ? 'Tap to collapse' : 'Tap to show details',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _nextKanji(kanjiList),
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Skip'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _masterKanji(context, kanji),
                        icon: const Icon(Icons.check),
                        label: const Text('Mastered'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF8b6f47).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
