import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';
import '../models/vocabulary_item.dart';
import '../models/sentence_item.dart';
import '../models/user_settings.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _isLoading = true;
  bool _showAnswer = false;
  int _currentIndex = 0;
  List<dynamic> _reviewItems = [];
  int _reviewedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadReviewItems();
  }

  Future<void> _loadReviewItems() async {
    final provider = Provider.of<StudyProvider>(context, listen: false);
    await provider.loadDueReviews();

    setState(() {
      // Combine vocabulary and sentences, shuffle them
      _reviewItems = [
        ...provider.dueVocabulary,
        ...provider.dueSentences,
      ]..shuffle();
      _isLoading = false;
    });
  }

  void _handleDifficulty(ReviewDifficulty difficulty) async {
    if (_currentIndex >= _reviewItems.length) return;

    final provider = Provider.of<StudyProvider>(context, listen: false);
    final currentItem = _reviewItems[_currentIndex];

    if (currentItem is VocabularyItem) {
      await provider.reviewVocabulary(currentItem, difficulty);
    } else if (currentItem is SentenceItem) {
      await provider.reviewSentence(currentItem, difficulty);
    }

    setState(() {
      _reviewedCount++;
      _showAnswer = false;
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Review'),
        actions: [
          if (_reviewItems.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_currentIndex + 1}/${_reviewItems.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8b6f47)),
              ),
            )
          : _reviewItems.isEmpty
              ? _buildEmptyState()
              : _currentIndex >= _reviewItems.length
                  ? _buildCompletedState()
                  : _buildReviewCard(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 24),
            const Text(
              'All caught up!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8b6f47),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No reviews due today.\nKeep learning new words!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration,
              size: 100,
              color: Colors.amber.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'Review Complete!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8b6f47),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You reviewed $_reviewedCount items today.\nGreat job keeping up your streak!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '+${_reviewedCount * 5} XP',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard() {
    final currentItem = _reviewItems[_currentIndex];
    final isVocabulary = currentItem is VocabularyItem;

    final String japanese;
    final String romaji;
    final String english;
    final String category;

    if (currentItem is VocabularyItem) {
      japanese = currentItem.japanese;
      romaji = currentItem.romaji;
      english = currentItem.english;
      category = currentItem.category;
    } else {
      final item = currentItem as SentenceItem;
      japanese = item.japanese;
      romaji = item.romaji;
      english = item.english;
      category = item.category;
    }

    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: _reviewItems.isEmpty ? 0 : _currentIndex / _reviewItems.length,
          backgroundColor: const Color(0xFF8b6f47).withValues(alpha: 0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8b6f47)),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Card type indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isVocabulary ? Icons.text_fields : Icons.format_quote,
                      size: 16,
                      color: const Color(0xFF8b6f47),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isVocabulary ? 'Vocabulary' : 'Sentence',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8b6f47),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8b6f47).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8b6f47),
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Main card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InkWell(
                    onTap: () => setState(() => _showAnswer = true),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Japanese text
                          Text(
                            japanese,
                            style: TextStyle(
                              fontSize: isVocabulary ? 48 : 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2d2d2d),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 12),

                          // Romaji
                          Text(
                            romaji,
                            style: TextStyle(
                              fontSize: isVocabulary ? 18 : 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          if (_showAnswer) ...[
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 24),

                            // English translation
                            Text(
                              english,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8b6f47),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ] else ...[
                            const SizedBox(height: 32),
                            Text(
                              'Tap to reveal answer',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Difficulty buttons
                if (_showAnswer) _buildDifficultyButtons() else const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyButtons() {
    return Column(
      children: [
        const Text(
          'How well did you remember?',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Hard button
            Expanded(
              child: _DifficultyButton(
                label: 'Hard',
                subtitle: '1 day',
                color: Colors.red.shade400,
                onPressed: () => _handleDifficulty(ReviewDifficulty.hard),
              ),
            ),
            const SizedBox(width: 12),
            // Good button
            Expanded(
              child: _DifficultyButton(
                label: 'Good',
                subtitle: '3 days',
                color: Colors.orange.shade400,
                onPressed: () => _handleDifficulty(ReviewDifficulty.good),
              ),
            ),
            const SizedBox(width: 12),
            // Easy button
            Expanded(
              child: _DifficultyButton(
                label: 'Easy',
                subtitle: '7+ days',
                color: Colors.green.shade400,
                onPressed: () => _handleDifficulty(ReviewDifficulty.easy),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onPressed;

  const _DifficultyButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
