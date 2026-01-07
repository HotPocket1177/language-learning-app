import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';
import '../models/sentence_item.dart';

class SentencesScreen extends StatefulWidget {
  const SentencesScreen({super.key});

  @override
  State<SentencesScreen> createState() => _SentencesScreenState();
}

class _SentencesScreenState extends State<SentencesScreen> {
  String? selectedCategory;
  List<SentenceItem> currentList = [];
  int currentIndex = 0;
  bool showEnglish = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategory();
    });
  }

  void _loadCategory() {
    final provider = Provider.of<StudyProvider>(context, listen: false);
    if (selectedCategory == null && provider.sentenceCategories.isNotEmpty) {
      selectedCategory = provider.sentenceCategories.first;
    }
    if (selectedCategory != null) {
      currentList = provider.getSentencesByCategory(selectedCategory!);
      currentIndex = 0;
      showEnglish = false;
      setState(() {});
    }
  }

  void _nextSentence() {
    final provider = Provider.of<StudyProvider>(context, listen: false);
    if (currentList.isNotEmpty) {
      provider.masterSentence(currentList[currentIndex]);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sentence mastered! +10 XP'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );

      // Reload the list
      currentList = provider.getSentencesByCategory(selectedCategory!);
      if (currentList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All sentences in this category mastered!'),
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
      provider.addSentenceToPractice(currentList[currentIndex]);

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
            content: Text('No more sentences in this category'),
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
        title: const Text('Sentences'),
        actions: [
          if (currentList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.shuffle),
              onPressed: _shuffleList,
              tooltip: 'Shuffle',
            ),
        ],
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          final categories = provider.sentenceCategories;

          if (categories.isEmpty) {
            return const Center(
              child: Text('No sentences available'),
            );
          }

          return Column(
            children: [
              // Category Selector
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.white,
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
                          selectedColor: const Color(0xFF8b6f47).withValues(alpha: 0.3),
                          backgroundColor: Colors.grey[200],
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
                              'All sentences mastered!',
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
                                        color: const Color(0xFF8b6f47),
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
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            currentList[currentIndex].romaji,
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ] else ...[
                                          Text(
                                            currentList[currentIndex].english,
                                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                  color: const Color(0xFF8b6f47),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 24),
                                          Text(
                                            currentList[currentIndex].japanese,
                                            style: const TextStyle(
                                              fontSize: 28,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            currentList[currentIndex].romaji,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  color: Colors.grey[600],
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
                                    onPressed: _nextSentence,
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
    );
  }
}
