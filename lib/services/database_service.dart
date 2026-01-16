import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_stats.dart';
import '../models/vocabulary_item.dart';
import '../models/sentence_item.dart';
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
      await _supabase.from('user_stats').upsert({
        'user_id': userId,
        'level': stats.level,
        'xp': stats.xp,
        'total_xp': stats.xp, // Can track total XP separately if needed
        'current_streak': stats.currentStreak,
        'longest_streak': stats.longestStreak,
        'last_study_date': stats.lastStudyDate?.toIso8601String(),
        'selected_language': selectedLanguage,
        'total_words_learned': stats.totalWordsLearned,
        'total_sentences_learned': stats.totalSentencesLearned,
        'total_kanji_learned': stats.totalKanjiLearned,
      });
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
      await _supabase.from('mastered_items').upsert({
        'user_id': userId,
        'item_id': item.id,
        'item_type': 'vocabulary',
        'language_code': languageCode,
        'japanese_text': item.japanese,
        'romaji_text': item.romaji,
        'english_text': item.english,
        'category': item.category,
        'user_note': item.userNote,
      });
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
      await _supabase.from('mastered_items').upsert({
        'user_id': userId,
        'item_id': item.id,
        'item_type': 'sentence',
        'language_code': languageCode,
        'japanese_text': item.japanese,
        'romaji_text': item.romaji,
        'english_text': item.english,
        'category': item.category,
        'user_note': item.userNote,
      });
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
      await _supabase.from('mastered_items').upsert({
        'user_id': userId,
        'item_id': kanjiId,
        'item_type': 'kanji',
        'language_code': languageCode,
        'japanese_text': kanjiText,
        'romaji_text': '',
        'english_text': kanjiText,
        'category': 'Kanji',
      });
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
      await _supabase.from('practice_items').upsert({
        'user_id': userId,
        'item_id': item.id,
        'item_type': 'vocabulary',
        'language_code': languageCode,
        'japanese_text': item.japanese,
        'romaji_text': item.romaji,
        'english_text': item.english,
        'category': item.category,
      });
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
      await _supabase.from('practice_items').upsert({
        'user_id': userId,
        'item_id': item.id,
        'item_type': 'sentence',
        'language_code': languageCode,
        'japanese_text': item.japanese,
        'romaji_text': item.romaji,
        'english_text': item.english,
        'category': item.category,
      });
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
}
