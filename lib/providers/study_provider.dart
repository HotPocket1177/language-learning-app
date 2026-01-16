import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vocabulary_item.dart';
import '../models/sentence_item.dart';
import '../models/kanji_item.dart';
import '../models/user_stats.dart';
import '../models/language_content.dart';
import '../data/language_data.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class StudyProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  SupportedLanguage? _selectedLanguage;
  UserStats _userStats = UserStats();
  List<VocabularyItem> _masteredVocabulary = [];
  List<SentenceItem> _masteredSentences = [];
  List<String> _masteredKanji = [];
  List<VocabularyItem> _practiceVocabulary = [];
  List<SentenceItem> _practiceSentences = [];

  // Getters
  SupportedLanguage? get selectedLanguage => _selectedLanguage;
  UserStats get userStats => _userStats;
  List<VocabularyItem> get masteredVocabulary => _masteredVocabulary;
  List<SentenceItem> get masteredSentences => _masteredSentences;
  List<String> get masteredKanji => _masteredKanji;
  List<VocabularyItem> get practiceVocabulary => _practiceVocabulary;
  List<SentenceItem> get practiceSentences => _practiceSentences;

  // Auth getters
  bool get isSignedIn => _authService.isSignedIn;
  bool get isGuest => _authService.isGuest;
  String? get currentUserId => _authService.currentUserId;
  String get username => _authService.username;

  LanguageContent? get currentLanguageContent {
    if (_selectedLanguage == null) return null;
    return languageContentMap[_selectedLanguage];
  }

  List<VocabularyItem> get availableVocabulary {
    final content = currentLanguageContent;
    if (content == null) return [];
    final masteredIds = _masteredVocabulary.map((e) => e.id).toSet();
    final practiceIds = _practiceVocabulary.map((e) => e.id).toSet();
    return content.vocabulary
        .where((item) => !masteredIds.contains(item.id) && !practiceIds.contains(item.id))
        .toList();
  }

  List<SentenceItem> get availableSentences {
    final content = currentLanguageContent;
    if (content == null) return [];
    final masteredIds = _masteredSentences.map((e) => e.id).toSet();
    final practiceIds = _practiceSentences.map((e) => e.id).toSet();
    return content.sentences
        .where((item) => !masteredIds.contains(item.id) && !practiceIds.contains(item.id))
        .toList();
  }

  List<KanjiItem> get availableKanji {
    final content = currentLanguageContent;
    if (content?.specialContent == null) return [];
    return content!.specialContent!
        .where((item) => !_masteredKanji.contains(item.id))
        .toList();
  }

  bool get hasSpecialContent {
    return _selectedLanguage?.hasSpecialContent ?? false;
  }

  // Select language
  Future<void> selectLanguage(SupportedLanguage language) async {
    _selectedLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language.code);

    // Save to Supabase if signed in
    if (isSignedIn && currentUserId != null) {
      try {
        await _databaseService.saveUserStats(
          userId: currentUserId!,
          stats: _userStats,
          selectedLanguage: language.code,
        );
      } catch (e) {
        debugPrint('Failed to save language to Supabase: $e');
      }
    }

    notifyListeners();
  }

  // Load data from Supabase or local storage
  Future<void> loadData() async {
    // Try to load from Supabase if signed in
    if (isSignedIn && currentUserId != null) {
      try {
        await _loadFromSupabase();
        return;
      } catch (e) {
        debugPrint('Failed to load from Supabase, using local storage: $e');
      }
    }

    // Fall back to local storage
    await _loadFromLocal();
  }

  // Load from Supabase
  Future<void> _loadFromSupabase() async {
    if (currentUserId == null) return;

    try {
      // Load user stats
      final statsData = await _databaseService.loadUserStats(currentUserId!);

      if (statsData != null) {
        // Parse stats
        _userStats = UserStats(
          userName: username,
          level: statsData['level'] ?? 1,
          xp: statsData['xp'] ?? 0,
          currentStreak: statsData['current_streak'] ?? 0,
          longestStreak: statsData['longest_streak'] ?? 0,
          totalWordsLearned: statsData['total_words_learned'] ?? 0,
          totalSentencesLearned: statsData['total_sentences_learned'] ?? 0,
          totalKanjiLearned: statsData['total_kanji_learned'] ?? 0,
          lastStudyDate: statsData['last_study_date'] != null
              ? DateTime.parse(statsData['last_study_date'])
              : null,
        );

        // Load selected language
        final languageCode = statsData['selected_language'] as String?;
        if (languageCode != null) {
          _selectedLanguage = SupportedLanguage.fromCode(languageCode);
        }
      }

      // Load mastered and practice items if language is selected
      if (_selectedLanguage != null) {
        final langCode = _selectedLanguage!.code;

        final results = await Future.wait([
          _databaseService.loadMasteredVocabulary(
            userId: currentUserId!,
            languageCode: langCode,
          ),
          _databaseService.loadMasteredSentences(
            userId: currentUserId!,
            languageCode: langCode,
          ),
          _databaseService.loadMasteredKanji(
            userId: currentUserId!,
            languageCode: langCode,
          ),
          _databaseService.loadPracticeVocabulary(
            userId: currentUserId!,
            languageCode: langCode,
          ),
          _databaseService.loadPracticeSentences(
            userId: currentUserId!,
            languageCode: langCode,
          ),
        ]);

        _masteredVocabulary = results[0] as List<VocabularyItem>;
        _masteredSentences = results[1] as List<SentenceItem>;
        _masteredKanji = results[2] as List<String>;
        _practiceVocabulary = results[3] as List<VocabularyItem>;
        _practiceSentences = results[4] as List<SentenceItem>;

        // Cache to local storage
        await _saveToLocal();
      }

      notifyListeners();
    } catch (e) {
      throw 'Failed to load data from Supabase: $e';
    }
  }

  // Load from local storage
  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();

    // Load selected language
    final languageCode = prefs.getString('selectedLanguage');
    if (languageCode != null) {
      _selectedLanguage = SupportedLanguage.fromCode(languageCode);
    }

    // Only load other data if language is selected
    if (_selectedLanguage != null) {
      // Load user stats
      final statsJson = prefs.getString('userStats_${_selectedLanguage!.code}');
      if (statsJson != null) {
        _userStats = UserStats.fromJson(json.decode(statsJson));
      }

      // Load mastered vocabulary
      final vocabJson = prefs.getString('masteredVocabulary_${_selectedLanguage!.code}');
      if (vocabJson != null) {
        final List<dynamic> decoded = json.decode(vocabJson);
        _masteredVocabulary = decoded.map((e) => VocabularyItem.fromJson(e)).toList();
      }

      // Load mastered sentences
      final sentJson = prefs.getString('masteredSentences_${_selectedLanguage!.code}');
      if (sentJson != null) {
        final List<dynamic> decoded = json.decode(sentJson);
        _masteredSentences = decoded.map((e) => SentenceItem.fromJson(e)).toList();
      }

      // Load mastered kanji
      final kanjiJson = prefs.getString('masteredKanji_${_selectedLanguage!.code}');
      if (kanjiJson != null) {
        _masteredKanji = List<String>.from(json.decode(kanjiJson));
      }

      // Load practice vocabulary
      final practiceVocabJson = prefs.getString('practiceVocabulary_${_selectedLanguage!.code}');
      if (practiceVocabJson != null) {
        final List<dynamic> decoded = json.decode(practiceVocabJson);
        _practiceVocabulary = decoded.map((e) => VocabularyItem.fromJson(e)).toList();
      }

      // Load practice sentences
      final practiceSentJson = prefs.getString('practiceSentences_${_selectedLanguage!.code}');
      if (practiceSentJson != null) {
        final List<dynamic> decoded = json.decode(practiceSentJson);
        _practiceSentences = decoded.map((e) => SentenceItem.fromJson(e)).toList();
      }
    }

    notifyListeners();
  }

  // Save to local storage
  Future<void> _saveToLocal() async {
    if (_selectedLanguage == null) return;

    final prefs = await SharedPreferences.getInstance();
    final langCode = _selectedLanguage!.code;

    await prefs.setString('userStats_$langCode', json.encode(_userStats.toJson()));
    await prefs.setString('masteredVocabulary_$langCode',
        json.encode(_masteredVocabulary.map((e) => e.toJson()).toList()));
    await prefs.setString('masteredSentences_$langCode',
        json.encode(_masteredSentences.map((e) => e.toJson()).toList()));
    await prefs.setString('masteredKanji_$langCode', json.encode(_masteredKanji));
    await prefs.setString('practiceVocabulary_$langCode',
        json.encode(_practiceVocabulary.map((e) => e.toJson()).toList()));
    await prefs.setString('practiceSentences_$langCode',
        json.encode(_practiceSentences.map((e) => e.toJson()).toList()));
  }

  // Save data (auto-sync to Supabase)
  Future<void> _saveData() async {
    // Always save to local storage
    await _saveToLocal();

    // Sync to Supabase if signed in
    if (isSignedIn && currentUserId != null && _selectedLanguage != null) {
      try {
        await _databaseService.syncAllData(
          userId: currentUserId!,
          languageCode: _selectedLanguage!.code,
          stats: _userStats,
          masteredVocabulary: _masteredVocabulary,
          masteredSentences: _masteredSentences,
          masteredKanji: _masteredKanji,
          practiceVocabulary: _practiceVocabulary,
          practiceSentences: _practiceSentences,
        );
      } catch (e) {
        debugPrint('Failed to sync to Supabase: $e');
        // Continue anyway - data is saved locally
      }
    }
  }

  // Master a vocabulary word
  Future<void> masterVocabulary(VocabularyItem item) async {
    if (!_masteredVocabulary.any((e) => e.id == item.id)) {
      _masteredVocabulary.add(item);
      _practiceVocabulary.removeWhere((e) => e.id == item.id);
      _userStats.addXp(10);
      _userStats.totalWordsLearned++;
      _userStats.updateStreak();

      await _saveData();

      // Save individual item to Supabase
      if (isSignedIn && currentUserId != null && _selectedLanguage != null) {
        try {
          await _databaseService.saveMasteredVocabulary(
            userId: currentUserId!,
            languageCode: _selectedLanguage!.code,
            item: item,
          );
        } catch (e) {
          debugPrint('Failed to save mastered vocabulary to Supabase: $e');
        }
      }

      notifyListeners();
    }
  }

  // Master a sentence
  Future<void> masterSentence(SentenceItem item) async {
    if (!_masteredSentences.any((e) => e.id == item.id)) {
      _masteredSentences.add(item);
      _practiceSentences.removeWhere((e) => e.id == item.id);
      _userStats.addXp(10);
      _userStats.totalSentencesLearned++;
      _userStats.updateStreak();

      await _saveData();

      // Save individual item to Supabase
      if (isSignedIn && currentUserId != null && _selectedLanguage != null) {
        try {
          await _databaseService.saveMasteredSentence(
            userId: currentUserId!,
            languageCode: _selectedLanguage!.code,
            item: item,
          );
        } catch (e) {
          debugPrint('Failed to save mastered sentence to Supabase: $e');
        }
      }

      notifyListeners();
    }
  }

  // Master a kanji
  Future<void> masterKanji(String kanjiId) async {
    if (!_masteredKanji.contains(kanjiId)) {
      _masteredKanji.add(kanjiId);
      _userStats.addXp(10);
      _userStats.totalKanjiLearned++;
      _userStats.updateStreak();

      await _saveData();

      // Save individual item to Supabase
      if (isSignedIn && currentUserId != null && _selectedLanguage != null) {
        try {
          await _databaseService.saveMasteredKanji(
            userId: currentUserId!,
            languageCode: _selectedLanguage!.code,
            kanjiId: kanjiId,
            kanjiText: kanjiId,
          );
        } catch (e) {
          debugPrint('Failed to save mastered kanji to Supabase: $e');
        }
      }

      notifyListeners();
    }
  }

  // Add vocabulary to practice deck
  Future<void> addVocabularyToPractice(VocabularyItem item) async {
    if (!_practiceVocabulary.any((e) => e.id == item.id) &&
        !_masteredVocabulary.any((e) => e.id == item.id)) {
      _practiceVocabulary.add(item);
      await _saveData();
      notifyListeners();
    }
  }

  // Add sentence to practice deck
  Future<void> addSentenceToPractice(SentenceItem item) async {
    if (!_practiceSentences.any((e) => e.id == item.id) &&
        !_masteredSentences.any((e) => e.id == item.id)) {
      _practiceSentences.add(item);
      await _saveData();
      notifyListeners();
    }
  }

  // Remove from practice deck
  Future<void> removeVocabularyFromPractice(String id) async {
    _practiceVocabulary.removeWhere((e) => e.id == id);
    await _saveData();
    notifyListeners();
  }

  Future<void> removeSentenceFromPractice(String id) async {
    _practiceSentences.removeWhere((e) => e.id == id);
    await _saveData();
    notifyListeners();
  }

  // Update note for vocabulary
  Future<void> updateVocabularyNote(String id, String note) async {
    final index = _masteredVocabulary.indexWhere((e) => e.id == id);
    if (index != -1) {
      _masteredVocabulary[index] = _masteredVocabulary[index].copyWith(userNote: note);
      await _saveData();
      notifyListeners();
    }
  }

  // Update note for sentence
  Future<void> updateSentenceNote(String id, String note) async {
    final index = _masteredSentences.indexWhere((e) => e.id == id);
    if (index != -1) {
      _masteredSentences[index] = _masteredSentences[index].copyWith(userNote: note);
      await _saveData();
      notifyListeners();
    }
  }

  // Update user name
  Future<void> updateUserName(String name) async {
    _userStats.userName = name;
    await _saveData();
    notifyListeners();
  }

  // Get vocabulary by category
  List<VocabularyItem> getVocabularyByCategory(String category) {
    return availableVocabulary.where((item) => item.category == category).toList();
  }

  // Get sentences by category
  List<SentenceItem> getSentencesByCategory(String category) {
    return availableSentences.where((item) => item.category == category).toList();
  }

  // Get unique categories
  List<String> get vocabularyCategories {
    final content = currentLanguageContent;
    if (content == null) return [];
    return content.vocabulary.map((e) => e.category).toSet().toList()..sort();
  }

  List<String> get sentenceCategories {
    final content = currentLanguageContent;
    if (content == null) return [];
    return content.sentences.map((e) => e.category).toSet().toList()..sort();
  }
}
