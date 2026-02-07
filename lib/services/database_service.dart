import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_stats.dart';
import '../models/user_settings.dart';
import '../models/vocabulary_item.dart';
import '../models/sentence_item.dart';
import '../models/review_item.dart';
import 'supabase_service.dart';

class DatabaseService {
  final SupabaseClient _supabase = SupabaseService.client;

  // ============================================
  // USER STATS METHODS
  // ============================================

  // Save user stats
  Future<void> saveUserStats({
    required String userId,
    required UserStats stats,
    required String selectedLanguage,
  }) async {
    try {
      await _supabase.from('user_stats').upsert(
        {
          'user_id': userId,
          'level': stats.level,
          'xp': stats.xp,
          'total_xp': stats.xp,
          'current_streak': stats.currentStreak,
          'longest_streak': stats.longestStreak,
          'last_study_date': stats.lastStudyDate?.toIso8601String(),
          'selected_language': selectedLanguage,
          'total_words_learned': stats.totalWordsLearned,
          'total_sentences_learned': stats.totalSentencesLearned,
          'total_kanji_learned': stats.totalKanjiLearned,
        },
        onConflict: 'user_id',
      );
    } on PostgrestException catch (e) {
      throw 'Failed to save stats: ${e.message}';
    } catch (e) {
      throw 'Failed to save stats: $e';
    }
  }

  // Load user stats
  Future<Map<String, dynamic>?> loadUserStats(String userId) async {
    try {
      final response = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } on PostgrestException catch (e) {
      throw 'Failed to load stats: ${e.message}';
    } catch (e) {
      throw 'Failed to load stats: $e';
    }
  }

  // ============================================
  // MASTERED ITEMS METHODS
  // ============================================

  // Save mastered vocabulary item
  Future<void> saveMasteredVocabulary({
    required String userId,
    required String languageCode,
    required VocabularyItem item,
  }) async {
    try {
      await _supabase.from('mastered_items').upsert(
        {
          'user_id': userId,
          'item_id': item.id,
          'item_type': 'vocabulary',
          'language_code': languageCode,
          'japanese_text': item.japanese,
          'romaji_text': item.romaji,
          'english_text': item.english,
          'category': item.category,
          'user_note': item.userNote,
          'next_review_date': item.nextReviewDate?.toIso8601String().split('T')[0],
          'review_interval': item.reviewInterval,
          'times_reviewed': item.timesReviewed,
          'ease_factor': item.easeFactor,
          'last_reviewed_at': item.lastReviewedAt?.toIso8601String(),
        },
        onConflict: 'user_id,item_id,language_code',
      );
    } on PostgrestException catch (e) {
      throw 'Failed to save mastered vocabulary: ${e.message}';
    } catch (e) {
      throw 'Failed to save mastered vocabulary: $e';
    }
  }

  // Save mastered sentence item
  Future<void> saveMasteredSentence({
    required String userId,
    required String languageCode,
    required SentenceItem item,
  }) async {
    try {
      await _supabase.from('mastered_items').upsert(
        {
          'user_id': userId,
          'item_id': item.id,
          'item_type': 'sentence',
          'language_code': languageCode,
          'japanese_text': item.japanese,
          'romaji_text': item.romaji,
          'english_text': item.english,
          'category': item.category,
          'user_note': item.userNote,
          'next_review_date': item.nextReviewDate?.toIso8601String().split('T')[0],
          'review_interval': item.reviewInterval,
          'times_reviewed': item.timesReviewed,
          'ease_factor': item.easeFactor,
          'last_reviewed_at': item.lastReviewedAt?.toIso8601String(),
        },
        onConflict: 'user_id,item_id,language_code',
      );
    } on PostgrestException catch (e) {
      throw 'Failed to save mastered sentence: ${e.message}';
    } catch (e) {
      throw 'Failed to save mastered sentence: $e';
    }
  }

  // Save mastered kanji
  Future<void> saveMasteredKanji({
    required String userId,
    required String languageCode,
    required String kanjiId,
    required String kanjiText,
  }) async {
    try {
      await _supabase.from('mastered_items').upsert(
        {
          'user_id': userId,
          'item_id': kanjiId,
          'item_type': 'kanji',
          'language_code': languageCode,
          'japanese_text': kanjiText,
          'romaji_text': '',
          'english_text': kanjiText,
          'category': 'Kanji',
        },
        onConflict: 'user_id,item_id,language_code',
      );
    } on PostgrestException catch (e) {
      throw 'Failed to save mastered kanji: ${e.message}';
    } catch (e) {
      throw 'Failed to save mastered kanji: $e';
    }
  }

  // Load mastered vocabulary
  Future<List<VocabularyItem>> loadMasteredVocabulary({
    required String userId,
    required String languageCode,
  }) async {
    try {
      final response = await _supabase
          .from('mastered_items')
          .select()
          .eq('user_id', userId)
          .eq('language_code', languageCode)
          .eq('item_type', 'vocabulary');

      return (response as List).map((item) {
        return VocabularyItem(
          id: item['item_id'] as String,
          japanese: item['japanese_text'] as String,
          romaji: item['romaji_text'] as String? ?? '',
          english: item['english_text'] as String,
          category: item['category'] as String? ?? 'General',
          userNote: item['user_note'] as String?,
          srsData: SrsData(
            nextReviewDate: item['next_review_date'] != null
                ? DateTime.parse(item['next_review_date'])
                : null,
            reviewInterval: item['review_interval'] ?? 1,
            timesReviewed: item['times_reviewed'] ?? 0,
            easeFactor: (item['ease_factor'] ?? 2.5).toDouble(),
            lastReviewedAt: item['last_reviewed_at'] != null
                ? DateTime.parse(item['last_reviewed_at'])
                : null,
          ),
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw 'Failed to load mastered vocabulary: ${e.message}';
    } catch (e) {
      throw 'Failed to load mastered vocabulary: $e';
    }
  }

  // Load mastered sentences
  Future<List<SentenceItem>> loadMasteredSentences({
    required String userId,
    required String languageCode,
  }) async {
    try {
      final response = await _supabase
          .from('mastered_items')
          .select()
          .eq('user_id', userId)
          .eq('language_code', languageCode)
          .eq('item_type', 'sentence');

      return (response as List).map((item) {
        return SentenceItem(
          id: item['item_id'] as String,
          japanese: item['japanese_text'] as String,
          romaji: item['romaji_text'] as String? ?? '',
          english: item['english_text'] as String,
          category: item['category'] as String? ?? 'General',
          userNote: item['user_note'] as String?,
          srsData: SrsData(
            nextReviewDate: item['next_review_date'] != null
                ? DateTime.parse(item['next_review_date'])
                : null,
            reviewInterval: item['review_interval'] ?? 1,
            timesReviewed: item['times_reviewed'] ?? 0,
            easeFactor: (item['ease_factor'] ?? 2.5).toDouble(),
            lastReviewedAt: item['last_reviewed_at'] != null
                ? DateTime.parse(item['last_reviewed_at'])
                : null,
          ),
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw 'Failed to load mastered sentences: ${e.message}';
    } catch (e) {
      throw 'Failed to load mastered sentences: $e';
    }
  }

  // Load mastered kanji IDs
  Future<List<String>> loadMasteredKanji({
    required String userId,
    required String languageCode,
  }) async {
    try {
      final response = await _supabase
          .from('mastered_items')
          .select('item_id')
          .eq('user_id', userId)
          .eq('language_code', languageCode)
          .eq('item_type', 'kanji');

      return (response as List)
          .map((item) => item['item_id'] as String)
          .toList();
    } on PostgrestException catch (e) {
      throw 'Failed to load mastered kanji: ${e.message}';
    } catch (e) {
      throw 'Failed to load mastered kanji: $e';
    }
  }

  // ============================================
  // PRACTICE ITEMS METHODS
  // ============================================

  // Save practice vocabulary item
  Future<void> savePracticeVocabulary({
    required String userId,
    required String languageCode,
    required VocabularyItem item,
  }) async {
    try {
      await _supabase.from('practice_items').upsert(
        {
          'user_id': userId,
          'item_id': item.id,
          'item_type': 'vocabulary',
          'language_code': languageCode,
          'japanese_text': item.japanese,
          'romaji_text': item.romaji,
          'english_text': item.english,
          'category': item.category,
        },
        onConflict: 'user_id,item_id,language_code',
      );
    } on PostgrestException catch (e) {
      throw 'Failed to save practice vocabulary: ${e.message}';
    } catch (e) {
      throw 'Failed to save practice vocabulary: $e';
    }
  }

  // Save practice sentence item
  Future<void> savePracticeSentence({
    required String userId,
    required String languageCode,
    required SentenceItem item,
  }) async {
    try {
      await _supabase.from('practice_items').upsert(
        {
          'user_id': userId,
          'item_id': item.id,
          'item_type': 'sentence',
          'language_code': languageCode,
          'japanese_text': item.japanese,
          'romaji_text': item.romaji,
          'english_text': item.english,
          'category': item.category,
        },
        onConflict: 'user_id,item_id,language_code',
      );
    } on PostgrestException catch (e) {
      throw 'Failed to save practice sentence: ${e.message}';
    } catch (e) {
      throw 'Failed to save practice sentence: $e';
    }
  }

  // Load practice vocabulary
  Future<List<VocabularyItem>> loadPracticeVocabulary({
    required String userId,
    required String languageCode,
  }) async {
    try {
      final response = await _supabase
          .from('practice_items')
          .select()
          .eq('user_id', userId)
          .eq('language_code', languageCode)
          .eq('item_type', 'vocabulary');

      return (response as List).map((item) {
        return VocabularyItem(
          id: item['item_id'] as String,
          japanese: item['japanese_text'] as String,
          romaji: item['romaji_text'] as String? ?? '',
          english: item['english_text'] as String,
          category: item['category'] as String? ?? 'General',
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw 'Failed to load practice vocabulary: ${e.message}';
    } catch (e) {
      throw 'Failed to load practice vocabulary: $e';
    }
  }

  // Load practice sentences
  Future<List<SentenceItem>> loadPracticeSentences({
    required String userId,
    required String languageCode,
  }) async {
    try {
      final response = await _supabase
          .from('practice_items')
          .select()
          .eq('user_id', userId)
          .eq('language_code', languageCode)
          .eq('item_type', 'sentence');

      return (response as List).map((item) {
        return SentenceItem(
          id: item['item_id'] as String,
          japanese: item['japanese_text'] as String,
          romaji: item['romaji_text'] as String? ?? '',
          english: item['english_text'] as String,
          category: item['category'] as String? ?? 'General',
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw 'Failed to load practice sentences: ${e.message}';
    } catch (e) {
      throw 'Failed to load practice sentences: $e';
    }
  }

  // Delete practice item
  Future<void> deletePracticeItem({
    required String userId,
    required String languageCode,
    required String itemId,
  }) async {
    try {
      await _supabase
          .from('practice_items')
          .delete()
          .eq('user_id', userId)
          .eq('language_code', languageCode)
          .eq('item_id', itemId);
    } on PostgrestException catch (e) {
      throw 'Failed to delete practice item: ${e.message}';
    } catch (e) {
      throw 'Failed to delete practice item: $e';
    }
  }

  // Clear all practice items for a language
  Future<void> clearPracticeItems({
    required String userId,
    required String languageCode,
  }) async {
    try {
      await _supabase
          .from('practice_items')
          .delete()
          .eq('user_id', userId)
          .eq('language_code', languageCode);
    } on PostgrestException catch (e) {
      throw 'Failed to clear practice items: ${e.message}';
    } catch (e) {
      throw 'Failed to clear practice items: $e';
    }
  }

  // ============================================
  // SYNC ALL DATA
  // ============================================

  // Sync all user data to Supabase
  Future<void> syncAllData({
    required String userId,
    required String languageCode,
    required UserStats stats,
    required List<VocabularyItem> masteredVocabulary,
    required List<SentenceItem> masteredSentences,
    required List<String> masteredKanji,
    required List<VocabularyItem> practiceVocabulary,
    required List<SentenceItem> practiceSentences,
  }) async {
    try {
      // Save stats
      await saveUserStats(
        userId: userId,
        stats: stats,
        selectedLanguage: languageCode,
      );

      // Save mastered items
      for (var item in masteredVocabulary) {
        await saveMasteredVocabulary(
          userId: userId,
          languageCode: languageCode,
          item: item,
        );
      }

      for (var item in masteredSentences) {
        await saveMasteredSentence(
          userId: userId,
          languageCode: languageCode,
          item: item,
        );
      }

      for (var kanjiId in masteredKanji) {
        await saveMasteredKanji(
          userId: userId,
          languageCode: languageCode,
          kanjiId: kanjiId,
          kanjiText: kanjiId,
        );
      }

      // Clear and save practice items
      await clearPracticeItems(userId: userId, languageCode: languageCode);

      for (var item in practiceVocabulary) {
        await savePracticeVocabulary(
          userId: userId,
          languageCode: languageCode,
          item: item,
        );
      }

      for (var item in practiceSentences) {
        await savePracticeSentence(
          userId: userId,
          languageCode: languageCode,
          item: item,
        );
      }
    } catch (e) {
      throw 'Failed to sync all data: $e';
    }
  }

  // ============================================
  // USER SETTINGS METHODS
  // ============================================

  /// Load user settings
  Future<UserSettings> loadUserSettings(String userId) async {
    try {
      final response = await _supabase
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return const UserSettings();
      }
      return UserSettings.fromJson(response);
    } on PostgrestException {
      return const UserSettings();
    } catch (_) {
      return const UserSettings();
    }
  }

  /// Save user settings
  Future<void> saveUserSettings({
    required String userId,
    required UserSettings settings,
  }) async {
    try {
      await _supabase.from('user_settings').upsert(
        {
          'user_id': userId,
          ...settings.toJson(),
        },
        onConflict: 'user_id',
      );
    } on PostgrestException catch (e) {
      throw 'Failed to save settings: ${e.message}';
    } catch (e) {
      throw 'Failed to save settings: $e';
    }
  }

  // ============================================
  // SRS (SPACED REPETITION) METHODS
  // ============================================

  /// Update SRS data for a mastered vocabulary item
  Future<void> updateVocabularySrs({
    required String userId,
    required String languageCode,
    required VocabularyItem item,
  }) async {
    try {
      await _supabase.from('mastered_items').update({
        'next_review_date': item.nextReviewDate?.toIso8601String().split('T')[0],
        'review_interval': item.reviewInterval,
        'times_reviewed': item.timesReviewed,
        'ease_factor': item.easeFactor,
        'last_reviewed_at': DateTime.now().toIso8601String(),
        'user_note': item.userNote,
      }).eq('user_id', userId).eq('item_id', item.id).eq('language_code', languageCode);
    } on PostgrestException catch (e) {
      throw 'Failed to update SRS data: ${e.message}';
    } catch (e) {
      throw 'Failed to update SRS data: $e';
    }
  }

  /// Update SRS data for a mastered sentence item
  Future<void> updateSentenceSrs({
    required String userId,
    required String languageCode,
    required SentenceItem item,
  }) async {
    try {
      await _supabase.from('mastered_items').update({
        'next_review_date': item.nextReviewDate?.toIso8601String().split('T')[0],
        'review_interval': item.reviewInterval,
        'times_reviewed': item.timesReviewed,
        'ease_factor': item.easeFactor,
        'last_reviewed_at': DateTime.now().toIso8601String(),
        'user_note': item.userNote,
      }).eq('user_id', userId).eq('item_id', item.id).eq('language_code', languageCode);
    } on PostgrestException catch (e) {
      throw 'Failed to update SRS data: ${e.message}';
    } catch (e) {
      throw 'Failed to update SRS data: $e';
    }
  }

  /// Load vocabulary items due for review
  Future<List<VocabularyItem>> loadDueVocabulary({
    required String userId,
    required String languageCode,
    int? limit,
  }) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      var query = _supabase
          .from('mastered_items')
          .select()
          .eq('user_id', userId)
          .eq('language_code', languageCode)
          .eq('item_type', 'vocabulary')
          .or('next_review_date.is.null,next_review_date.lte.$today')
          .order('next_review_date', ascending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List).map((item) {
        return VocabularyItem(
          id: item['item_id'] as String,
          japanese: item['japanese_text'] as String,
          romaji: item['romaji_text'] as String? ?? '',
          english: item['english_text'] as String,
          category: item['category'] as String? ?? 'General',
          userNote: item['user_note'] as String?,
          srsData: SrsData(
            nextReviewDate: item['next_review_date'] != null
                ? DateTime.parse(item['next_review_date'])
                : null,
            reviewInterval: item['review_interval'] ?? 1,
            timesReviewed: item['times_reviewed'] ?? 0,
            easeFactor: (item['ease_factor'] ?? 2.5).toDouble(),
            lastReviewedAt: item['last_reviewed_at'] != null
                ? DateTime.parse(item['last_reviewed_at'])
                : null,
          ),
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw 'Failed to load due vocabulary: ${e.message}';
    } catch (e) {
      throw 'Failed to load due vocabulary: $e';
    }
  }

  /// Load sentences due for review
  Future<List<SentenceItem>> loadDueSentences({
    required String userId,
    required String languageCode,
    int? limit,
  }) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      var query = _supabase
          .from('mastered_items')
          .select()
          .eq('user_id', userId)
          .eq('language_code', languageCode)
          .eq('item_type', 'sentence')
          .or('next_review_date.is.null,next_review_date.lte.$today')
          .order('next_review_date', ascending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List).map((item) {
        return SentenceItem(
          id: item['item_id'] as String,
          japanese: item['japanese_text'] as String,
          romaji: item['romaji_text'] as String? ?? '',
          english: item['english_text'] as String,
          category: item['category'] as String? ?? 'General',
          userNote: item['user_note'] as String?,
          srsData: SrsData(
            nextReviewDate: item['next_review_date'] != null
                ? DateTime.parse(item['next_review_date'])
                : null,
            reviewInterval: item['review_interval'] ?? 1,
            timesReviewed: item['times_reviewed'] ?? 0,
            easeFactor: (item['ease_factor'] ?? 2.5).toDouble(),
            lastReviewedAt: item['last_reviewed_at'] != null
                ? DateTime.parse(item['last_reviewed_at'])
                : null,
          ),
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw 'Failed to load due sentences: ${e.message}';
    } catch (e) {
      throw 'Failed to load due sentences: $e';
    }
  }

  /// Get count of items due for review (total across all types)
  Future<int> getDueReviewCount({
    required String userId,
    required String languageCode,
  }) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await _supabase
          .from('mastered_items')
          .select('item_id')
          .eq('user_id', userId)
          .eq('language_code', languageCode)
          .or('next_review_date.is.null,next_review_date.lte.$today');

      return (response as List).length;
    } on PostgrestException {
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// Get count of due items by type
  Future<int> getDueCountByType({
    required String userId,
    required String languageCode,
    required String itemType,
  }) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await _supabase
          .from('mastered_items')
          .select('item_id')
          .eq('user_id', userId)
          .eq('language_code', languageCode)
          .eq('item_type', itemType)
          .or('next_review_date.is.null,next_review_date.lte.$today');

      return (response as List).length;
    } on PostgrestException {
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// Get review stats per type: returns {newCount, dueCount}
  Future<Map<String, int>> getReviewStats({
    required String userId,
    required String languageCode,
    required String itemType,
    required int totalAvailable,
  }) async {
    try {
      final dueCount = await getDueCountByType(
        userId: userId,
        languageCode: languageCode,
        itemType: itemType,
      );
      return {
        'newCount': totalAvailable,
        'dueCount': dueCount,
      };
    } catch (_) {
      return {'newCount': totalAvailable, 'dueCount': 0};
    }
  }
}
