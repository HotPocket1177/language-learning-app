import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';
import '../models/vocabulary_item.dart';
import '../models/sentence_item.dart';

class MasteredGalleryScreen extends StatefulWidget {
  const MasteredGalleryScreen({super.key});

  @override
  State<MasteredGalleryScreen> createState() => _MasteredGalleryScreenState();
}

class _MasteredGalleryScreenState extends State<MasteredGalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mastered Gallery'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF8b6f47).withValues(alpha: 0.1),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 24),
              tabs: const [
                Tab(
                  height: 52,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.text_fields, size: 20),
                      SizedBox(width: 8),
                      Text('Vocabulary'),
                    ],
                  ),
                ),
                Tab(
                  height: 52,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.format_quote, size: 20),
                      SizedBox(width: 8),
                      Text('Sentences'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _VocabularyList(vocabulary: provider.masteredVocabulary),
              _SentencesList(sentences: provider.masteredSentences),
            ],
          );
        },
      ),
    );
  }
}

// ============================================
// VOCABULARY LIST VIEW
// ============================================

class _VocabularyList extends StatelessWidget {
  final List<VocabularyItem> vocabulary;

  const _VocabularyList({required this.vocabulary});

  @override
  Widget build(BuildContext context) {
    if (vocabulary.isEmpty) {
      return _EmptyState(
        icon: Icons.book_outlined,
        title: 'No mastered vocabulary yet',
        subtitle: 'Start learning to see your progress here!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: vocabulary.length,
      itemBuilder: (context, index) {
        final item = vocabulary[index];
        return _VocabularyListTile(item: item);
      },
    );
  }
}

class _VocabularyListTile extends StatelessWidget {
  final VocabularyItem item;

  const _VocabularyListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('vocab_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) => _confirmRemove(context),
      onDismissed: (direction) => _removeItem(context),
      child: InkWell(
        onTap: () => _showNotesDialog(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF8b6f47).withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Japanese text (large)
                    Text(
                      item.japanese,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2d2d2d),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Romaji (medium)
                    Text(
                      item.romaji,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // English translation (smaller, brown)
                    Text(
                      item.english,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF8b6f47),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Right side: category tag + icons
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8b6f47).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8b6f47),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Icons row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Notes indicator
                      if (item.userNote != null && item.userNote!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.note,
                            size: 18,
                            color: const Color(0xFF8b6f47).withValues(alpha: 0.6),
                          ),
                        ),
                      // Delete button
                      GestureDetector(
                        onTap: () async {
                          final confirmed = await _confirmRemove(context);
                          if (confirmed == true && context.mounted) {
                            _removeItem(context);
                          }
                        },
                        child: Icon(
                          Icons.delete_outline,
                          size: 22,
                          color: Colors.red.shade300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmRemove(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Mastered'),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge,
            children: [
              const TextSpan(text: 'Remove '),
              TextSpan(
                text: item.japanese,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const TextSpan(text: ' from mastered gallery?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _removeItem(BuildContext context) {
    Provider.of<StudyProvider>(context, listen: false)
        .removeMasteredVocabulary(item.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.japanese} removed from mastered'),
        backgroundColor: Colors.orange.shade700,
      ),
    );
  }

  void _showNotesDialog(BuildContext context) {
    final noteController = TextEditingController(text: item.userNote ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Column(
          children: [
            Text(
              item.japanese,
              style: const TextStyle(fontSize: 32),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              item.romaji,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.english,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF8b6f47),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8b6f47).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8b6f47),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Notes:',
                  style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add notes about this word...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF8b6f47),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          // Remove button (left side)
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final confirmed = await _confirmRemove(context);
              if (confirmed == true && context.mounted) {
                _removeItem(context);
              }
            },
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Remove'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade400,
            ),
          ),
          // Cancel and Save buttons (right side)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Provider.of<StudyProvider>(context, listen: false)
                      .updateVocabularyNote(item.id, noteController.text);
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note saved'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================
// SENTENCES LIST VIEW
// ============================================

class _SentencesList extends StatelessWidget {
  final List<SentenceItem> sentences;

  const _SentencesList({required this.sentences});

  @override
  Widget build(BuildContext context) {
    if (sentences.isEmpty) {
      return _EmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'No mastered sentences yet',
        subtitle: 'Start learning to see your progress here!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sentences.length,
      itemBuilder: (context, index) {
        final item = sentences[index];
        return _SentenceListTile(item: item);
      },
    );
  }
}

class _SentenceListTile extends StatelessWidget {
  final SentenceItem item;

  const _SentenceListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('sentence_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) => _confirmRemove(context),
      onDismissed: (direction) => _removeItem(context),
      child: InkWell(
        onTap: () => _showNotesDialog(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF8b6f47).withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Japanese text
                    Text(
                      item.japanese,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2d2d2d),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Romaji
                    Text(
                      item.romaji,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // English translation
                    Text(
                      item.english,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8b6f47),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Right side: category tag + icons
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8b6f47).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8b6f47),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Icons row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Notes indicator
                      if (item.userNote != null && item.userNote!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.note,
                            size: 18,
                            color: const Color(0xFF8b6f47).withValues(alpha: 0.6),
                          ),
                        ),
                      // Delete button
                      GestureDetector(
                        onTap: () async {
                          final confirmed = await _confirmRemove(context);
                          if (confirmed == true && context.mounted) {
                            _removeItem(context);
                          }
                        },
                        child: Icon(
                          Icons.delete_outline,
                          size: 22,
                          color: Colors.red.shade300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmRemove(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Mastered'),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge,
            children: [
              const TextSpan(text: 'Remove this sentence from mastered gallery?\n\n'),
              TextSpan(
                text: item.japanese,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _removeItem(BuildContext context) {
    Provider.of<StudyProvider>(context, listen: false)
        .removeMasteredSentence(item.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sentence removed from mastered'),
        backgroundColor: Colors.orange.shade700,
      ),
    );
  }

  void _showNotesDialog(BuildContext context) {
    final noteController = TextEditingController(text: item.userNote ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Sentence Details',
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Japanese
              Text(
                item.japanese,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // Romaji
              Text(
                item.romaji,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              // English
              Text(
                item.english,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8b6f47),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // Category
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8b6f47).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8b6f47),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Your Notes:',
                style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add notes about this sentence...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF8b6f47),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          // Remove button (left side)
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final confirmed = await _confirmRemove(context);
              if (confirmed == true && context.mounted) {
                _removeItem(context);
              }
            },
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Remove'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade400,
            ),
          ),
          // Cancel and Save buttons (right side)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Provider.of<StudyProvider>(context, listen: false)
                      .updateSentenceNote(item.id, noteController.text);
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note saved'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================
// EMPTY STATE WIDGET
// ============================================

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: const Color(0xFF8b6f47).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF8b6f47),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
