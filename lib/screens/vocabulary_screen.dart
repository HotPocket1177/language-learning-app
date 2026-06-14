import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';
import '../models/vocabulary_item.dart';
import '../models/kuma_message.dart';
import '../services/kuma_service.dart';
import '../widgets/kuma_mascot.dart';
import '../widgets/kuma_speech_bubble.dart' show BubbleTailDirection;

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  String? selectedCategory;
  List<VocabularyItem> currentList = [];
  int currentIndex = 0;
  bool showEnglish = false;

  // Kuma state
  final GlobalKey<KumaMascotState> _kumaKey = GlobalKey();
  final KumaService _kumaService = KumaService();
  KumaEmotion _kumaEmotion = KumaEmotion.idle;
  String? _kumaBubbleText;
  bool _showKumaBubble = false;
  int _correctStreak = 0;

  @override
  void initState() {
    super.initState();
    _kumaService.load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategory();
    });
  }

  void _loadCategory() {
    final provider = Provider.of<StudyProvider>(context, listen: false);
    if (selectedCategory == null && provider.vocabularyCategories.isNotEmpty) {
      selectedCategory = provider.vocabularyCategories.first;
    }
    if (selectedCategory != null) {
      currentList = provider.getVocabularyByCategory(selectedCategory!);
      currentIndex = 0;
      showEnglish = false;
      setState(() {});
    }
  }

  void _nextWord() {
    final provider = Provider.of<StudyProvider>(context, listen: false);
    if (currentList.isNotEmpty) {
      provider.masterVocabulary(currentList[currentIndex]);
      _correctStreak++;

      // Kuma reaction: correct answer → excited
      if (_kumaService.showKuma) {
        KumaMessage reaction;
        if (_correctStreak >= 5 && _correctStreak % 5 == 0) {
          // 5 streak → celebrating
          reaction = _kumaService.getStreakReaction(_correctStreak);
        } else {
          reaction = _kumaService.getCorrectAnswerReaction();
        }
        setState(() {
          _kumaEmotion = reaction.emotion;
          _kumaBubbleText = reaction.text;
          _showKumaBubble = true;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Word mastered! +10 XP'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );

      // Reload the list
      currentList = provider.getVocabularyByCategory(selectedCategory!);
      if (currentList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All words in this category mastered!'),
            backgroundColor: Color(0xFF8b6f47),
          ),
        );
      } else {
        currentIndex = 0;
        showEnglish = false;
      }
      setState(() {});
    }
  }

  void _addToPractice() {
    final provider = Provider.of<StudyProvider>(context, listen: false);
    if (currentList.isNotEmpty) {
      provider.addVocabularyToPractice(currentList[currentIndex]);

      // Kuma reaction: wrong / needs practice → encouraging
      if (_kumaService.showKuma) {
        _correctStreak = 0;
        final reaction = _kumaService.getWrongAnswerReaction();
        setState(() {
          _kumaEmotion = reaction.emotion;
          _kumaBubbleText = reaction.text;
          _showKumaBubble = true;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to Practice Deck'),
          duration: Duration(seconds: 1),
        ),
      );

      _goToNext();
    }
  }

  void _goToNext() {
    if (currentList.isNotEmpty) {
      if (currentIndex < currentList.length - 1) {
        setState(() {
          currentIndex++;
          showEnglish = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No more words in this category'),
          ),
        );
      }
    }
  }

  void _shuffleList() {
    setState(() {
      currentList.shuffle();
      currentIndex = 0;
      showEnglish = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        actions: [
          if (currentList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.shuffle),
              onPressed: _shuffleList,
              tooltip: 'Shuffle',
            ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<StudyProvider>(
            builder: (context, provider, child) {
              final categories = provider.vocabularyCategories;

              if (categories.isEmpty) {
                return const Center(
                  child: Text('No vocabulary available'),
                );
              }

              return Column(
                children: [
                  // Category Selector
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).colorScheme.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Category',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: categories.map((category) {
                            final isSelected = category == selectedCategory;
                            return ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    selectedCategory = category;
                                    _loadCategory();
                                  });
                                }
                              },
                              selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // Flashcard Area
                  Expanded(
                    child: currentList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 80,
                                  color: Colors.green[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'All words mastered!',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try another category',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Progress Indicator
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${currentIndex + 1} / ${currentList.length}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      '$selectedCategory',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Flashcard
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showEnglish = !showEnglish;
                                      });
                                    },
                                    child: Card(
                                      elevation: 8,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(32),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (!showEnglish) ...[
                                              Text(
                                                currentList[currentIndex].japanese,
                                                style: const TextStyle(
                                                  fontSize: 48,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                currentList[currentIndex].romaji,
                                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                                                    ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ] else ...[
                                              Text(
                                                currentList[currentIndex].english,
                                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                      color: Theme.of(context).colorScheme.primary,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 24),
                                              Text(
                                                currentList[currentIndex].japanese,
                                                style: const TextStyle(
                                                  fontSize: 36,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                currentList[currentIndex].romaji,
                                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                                                    ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                            const SizedBox(height: 32),
                                            Text(
                                              showEnglish
                                                  ? 'Tap to hide translation'
                                                  : 'Tap to show translation',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                            ),
                                          ],
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
                                        onPressed: _addToPractice,
                                        icon: const Icon(Icons.fitness_center),
                                        label: const Text('Practice'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _nextWord,
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
                          ),
                  ),
                ],
              );
            },
          ),

          // Kuma in bottom-left corner (50x50)
          if (_kumaService.showKuma)
            Positioned(
              bottom: 16,
              left: 8,
              child: KumaMascot(
                key: _kumaKey,
                emotion: _kumaEmotion,
                size: 50,
                showMessage: _showKumaBubble,
                message: _kumaBubbleText,
                bubbleTailDirection: BubbleTailDirection.left,
                onBubbleDismissed: () {
                  setState(() => _showKumaBubble = false);
                },
              ),
            ),
        ],
      ),
    );
  }
}
