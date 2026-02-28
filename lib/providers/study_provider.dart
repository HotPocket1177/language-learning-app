import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vocabulary_item.dart';
import '../models/sentence_item.dart';
import '../models/kanji_item.dart';
import '../models/user_stats.dart';
import '../models/user_settings.dart';
import '../models/review_item.dart';
import '../models/language_content.dart';
import '../data/language_data.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

/// Study modes for per-section review
enum StudyMode {
  studyNew,
  reviewDue,
  practiceAll,
}

class StudyProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  SupportedLanguage? _selectedLanguage;
  UserStats _userStats = UserStats();
  UserSettings _userSettings = const UserSettings();
  List<VocabularyItem> _masteredVocabulary = [];
  List<SentenceItem> _masteredSentences = [];
  List<String> _masteredKanji = [];
  List<VocabularyItem> _practiceVocabulary = [];
  List<SentenceItem> _practiceSentences = [];

  // SRS review queues
  List<VocabularyItem> _dueVocabulary = [];
  List<SentenceItem> _dueSentences = [];
  int _dueReviewCount = 0;

  // Per-type due counts
  int _dueVocabularyCount = 0;
  int _dueSentencesCount = 0;
  int _dueKanjiCount = 0;

  // Getters
  SupportedLanguage? get selectedLanguage => _selectedLanguage;
  UserStats get userStats => _userStats;
  UserSettings get userSettings => _userSettings;
  List<VocabularyItem> get masteredVocabulary => _masteredVocabulary;
  List<SentenceItem> get masteredSentences => _masteredSentences;
  List<String> get masteredKanji => _masteredKanji;
  List<VocabularyItem> get practiceVocabulary => _practiceVocabulary;
  List<SentenceItem> get practiceSentences => _practiceSentences;

  // SRS getters
  List<VocabularyItem> get dueVocabulary => _dueVocabulary;
  List<SentenceItem> get dueSentences => _dueSentences;
  int get dueReviewCount => _dueReviewCount;

  // Per-type due count getters
  int get dueVocabularyCount => _dueVocabularyCount;
  int get dueSentencesCount => _dueSentencesCount;
  int get dueKanjiCount => _dueKanjiCount;

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

    // Sync to Supabase if signed in
    if (isSignedIn && currentUserId != null) {
      try {
        await _databaseService.saveUserStats(
          userId: currentUserId!,
          stats: _userStats,
          selectedLanguage: language.code,
        );
      } catch (_) {
        // Sync failed - data saved locally
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
      } catch (_) {
        // Supabase load failed - fall back to local storage
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

        // Update per-type due counts from local data
        _updateDueCountsFromLocal();

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

      // Update per-type due counts
      _updateDueCountsFromLocal();
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
      } catch (_) {
        // Sync failed - data saved locally
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

      // Sync to Supabase
      if (isSignedIn && currentUserId != null && _selectedLanguage != null) {
        try {
          await _databaseService.saveMasteredVocabulary(
            userId: currentUserId!,
            languageCode: _selectedLanguage!.code,
            item: item,
          );
        } catch (_) {
          // Sync failed - saved locally
        }
      }

      _updateDueCountsFromLocal();
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

      // Sync to Supabase
      if (isSignedIn && currentUserId != null && _selectedLanguage != null) {
        try {
          await _databaseService.saveMasteredSentence(
            userId: currentUserId!,
            languageCode: _selectedLanguage!.code,
            item: item,
          );
        } catch (_) {
          // Sync failed - saved locally
        }
      }

      _updateDueCountsFromLocal();
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

      // Sync to Supabase
      if (isSignedIn && currentUserId != null && _selectedLanguage != null) {
        try {
          await _databaseService.saveMasteredKanji(
            userId: currentUserId!,
            languageCode: _selectedLanguage!.code,
            kanjiId: kanjiId,
            kanjiText: kanjiId,
          );
        } catch (_) {
          // Sync failed - saved locally
        }
      }

      notifyListeners();
    }
  }

  // Award XP for completing a conversation
  Future<void> addConversationXp(int amount) async {
    _userStats.addXp(amount);
    _userStats.updateStreak();
    await _saveData();
    notifyListeners();
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

  // Remove vocabulary from mastered
  Future<void> removeMasteredVocabulary(String id) async {
    _masteredVocabulary.removeWhere((e) => e.id == id);
    await _saveData();
    _updateDueCountsFromLocal();
    notifyListeners();
  }

  // Remove sentence from mastered
  Future<void> removeMasteredSentence(String id) async {
    _masteredSentences.removeWhere((e) => e.id == id);
    await _saveData();
    _updateDueCountsFromLocal();
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

  // ============================================
  // SETTINGS METHODS
  // ============================================

  /// Load user settings from Supabase or local storage
  Future<UserSettings> loadSettings() async {
    if (isSignedIn && currentUserId != null) {
      try {
        _userSettings = await _databaseService.loadUserSettings(currentUserId!);
        return _userSettings;
      } catch (_) {
        // Fall back to local
      }
    }

    // Load from local storage
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('userSettings');
    if (settingsJson != null) {
      _userSettings = UserSettings.fromJson(json.decode(settingsJson));
    }
    return _userSettings;
  }

  /// Save user settings
  Future<void> saveSettings(UserSettings settings) async {
    _userSettings = settings;

    // Save locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userSettings', json.encode(settings.toJson()));

    // Sync to Supabase if signed in
    if (isSignedIn && currentUserId != null) {
      try {
        await _databaseService.saveUserSettings(
          userId: currentUserId!,
          settings: settings,
        );
      } catch (_) {
        // Sync failed - saved locally
      }
    }

    notifyListeners();
  }

  // ============================================
  // SRS (SPACED REPETITION) METHODS
  // ============================================

  /// Update per-type due counts from local data
  void _updateDueCountsFromLocal() {
    _dueVocabularyCount = _masteredVocabulary
        .where((item) => item.isDueForReview)
        .length;

    _dueSentencesCount = _masteredSentences
        .where((item) => item.isDueForReview)
        .length;

    // Kanji don't have SRS data in local model yet
    _dueKanjiCount = 0;

    _dueReviewCount = _dueVocabularyCount + _dueSentencesCount + _dueKanjiCount;
  }

  /// Load per-type due counts (for home screen display)
  Future<void> loadDueCounts() async {
    if (_selectedLanguage == null) return;

    if (isSignedIn && currentUserId != null) {
      try {
        final langCode = _selectedLanguage!.code;
        final results = await Future.wait([
          _databaseService.getDueCountByType(
            userId: currentUserId!,
            languageCode: langCode,
            itemType: 'vocabulary',
          ),
          _databaseService.getDueCountByType(
            userId: currentUserId!,
            languageCode: langCode,
            itemType: 'sentence',
          ),
          _databaseService.getDueCountByType(
            userId: currentUserId!,
            languageCode: langCode,
            itemType: 'kanji',
          ),
        ]);

        _dueVocabularyCount = results[0];
        _dueSentencesCount = results[1];
        _dueKanjiCount = results[2];
        _dueReviewCount = _dueVocabularyCount + _dueSentencesCount + _dueKanjiCount;
      } catch (_) {
        _updateDueCountsFromLocal();
      }
    } else {
      _updateDueCountsFromLocal();
    }

    notifyListeners();
  }

  /// Load items due for review today
  Future<void> loadDueReviews() async {
    if (_selectedLanguage == null) return;

    if (isSignedIn && currentUserId != null) {
      try {
        final results = await Future.wait([
          _databaseService.loadDueVocabulary(
            userId: currentUserId!,
            languageCode: _selectedLanguage!.code,
            limit: _userSettings.reviewWordsPerDay,
          ),
          _databaseService.loadDueSentences(
            userId: currentUserId!,
            languageCode: _selectedLanguage!.code,
            limit: _userSettings.reviewWordsPerDay,
          ),
          _databaseService.getDueReviewCount(
            userId: currentUserId!,
            languageCode: _selectedLanguage!.code,
          ),
        ]);

        _dueVocabulary = results[0] as List<VocabularyItem>;
        _dueSentences = results[1] as List<SentenceItem>;
        _dueReviewCount = results[2] as int;
      } catch (_) {
        _loadDueReviewsFromLocal();
      }
    } else {
      _loadDueReviewsFromLocal();
    }

    notifyListeners();
  }

  /// Load due reviews from local storage
  void _loadDueReviewsFromLocal() {
    _dueVocabulary = _masteredVocabulary
        .where((item) => item.isDueForReview)
        .take(_userSettings.reviewWordsPerDay)
        .toList();

    _dueSentences = _masteredSentences
        .where((item) => item.isDueForReview)
        .take(_userSettings.reviewWordsPerDay)
        .toList();

    _dueReviewCount = _masteredVocabulary.where((item) => item.isDueForReview).length +
        _masteredSentences.where((item) => item.isDueForReview).length;
  }

  /// Review a vocabulary item with difficulty rating
  Future<void> reviewVocabulary(VocabularyItem item, ReviewDifficulty difficulty) async {
    // Calculate new interval
    final newInterval = difficulty.calculateNextInterval(
      currentInterval: item.reviewInterval,
      easeFactor: item.easeFactor,
      settings: _userSettings,
    );

    // Calculate new ease factor
    final newEaseFactor = difficulty.adjustEaseFactor(item.easeFactor);

    // Calculate next review date
    final nextReviewDate = DateTime.now().add(Duration(days: newInterval));

    // Update the item
    final updatedItem = item.withUpdatedSrs(
      nextReviewDate: nextReviewDate,
      reviewInterval: newInterval,
      easeFactor: newEaseFactor,
    );

    // Update in mastered list
    final index = _masteredVocabulary.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _masteredVocabulary[index] = updatedItem;
    }

    // Remove from due list
    _dueVocabulary.removeWhere((e) => e.id == item.id);
    _dueReviewCount = (_dueReviewCount - 1).clamp(0, 9999);

    // Add XP for review
    _userStats.addXp(5);
    _userStats.updateStreak();

    // Save
    await _saveData();

    // Sync SRS data to Supabase
    if (isSignedIn && currentUserId != null && _selectedLanguage != null) {
      try {
        await _databaseService.updateVocabularySrs(
          userId: currentUserId!,
          languageCode: _selectedLanguage!.code,
          item: updatedItem,
        );
      } catch (_) {
        // Sync failed
      }
    }

    _updateDueCountsFromLocal();
    notifyListeners();
  }

  /// Review a sentence item with difficulty rating
  Future<void> reviewSentence(SentenceItem item, ReviewDifficulty difficulty) async {
    // Calculate new interval
    final newInterval = difficulty.calculateNextInterval(
      currentInterval: item.reviewInterval,
      easeFactor: item.easeFactor,
      settings: _userSettings,
    );

    // Calculate new ease factor
    final newEaseFactor = difficulty.adjustEaseFactor(item.easeFactor);

    // Calculate next review date
    final nextReviewDate = DateTime.now().add(Duration(days: newInterval));

    // Update the item
    final updatedItem = item.withUpdatedSrs(
      nextReviewDate: nextReviewDate,
      reviewInterval: newInterval,
      easeFactor: newEaseFactor,
    );

    // Update in mastered list
    final index = _masteredSentences.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _masteredSentences[index] = updatedItem;
    }

    // Remove from due list
    _dueSentences.removeWhere((e) => e.id == item.id);
    _dueReviewCount = (_dueReviewCount - 1).clamp(0, 9999);

    // Add XP for review
    _userStats.addXp(5);
    _userStats.updateStreak();

    // Save
    await _saveData();

    // Sync SRS data to Supabase
    if (isSignedIn && currentUserId != null && _selectedLanguage != null) {
      try {
        await _databaseService.updateSentenceSrs(
          userId: currentUserId!,
          languageCode: _selectedLanguage!.code,
          item: updatedItem,
        );
      } catch (_) {
        // Sync failed
      }
    }

    _updateDueCountsFromLocal();
    notifyListeners();
  }

  /// Master vocabulary with initial SRS scheduling
  Future<void> masterVocabularyWithSrs(VocabularyItem item, ReviewDifficulty difficulty) async {
    // Calculate initial interval based on difficulty
    final initialInterval = difficulty.calculateNextInterval(
      currentInterval: 1,
      easeFactor: 2.5,
      settings: _userSettings,
    );

    final nextReviewDate = DateTime.now().add(Duration(days: initialInterval));

    // Create item with SRS data
    final itemWithSrs = item.copyWith(
      srsData: SrsData(
        nextReviewDate: nextReviewDate,
        reviewInterval: initialInterval,
        timesReviewed: 1,
        easeFactor: difficulty.adjustEaseFactor(2.5),
        lastReviewedAt: DateTime.now(),
      ),
    );

    if (!_masteredVocabulary.any((e) => e.id == item.id)) {
      _masteredVocabulary.add(itemWithSrs);
      _practiceVocabulary.removeWhere((e) => e.id == item.id);
      _userStats.addXp(10);
      _userStats.totalWordsLearned++;
      _userStats.updateStreak();

      await _saveData();

      // Sync to Supabase
      if (isSignedIn && currentUserId != null && _selectedLanguage != null) {
        try {
          await _databaseService.saveMasteredVocabulary(
            userId: currentUserId!,
            languageCode: _selectedLanguage!.code,
            item: itemWithSrs,
          );
        } catch (_) {
          // Sync failed
        }
      }

      _updateDueCountsFromLocal();
      notifyListeners();
    }
  }

  /// Master sentence with initial SRS scheduling
  Future<void> masterSentenceWithSrs(SentenceItem item, ReviewDifficulty difficulty) async {
    // Calculate initial interval based on difficulty
    final initialInterval = difficulty.calculateNextInterval(
      currentInterval: 1,
      easeFactor: 2.5,
      settings: _userSettings,
    );

    final nextReviewDate = DateTime.now().add(Duration(days: initialInterval));

    // Create item with SRS data
    final itemWithSrs = item.copyWith(
      srsData: SrsData(
        nextReviewDate: nextReviewDate,
        reviewInterval: initialInterval,
        timesReviewed: 1,
        easeFactor: difficulty.adjustEaseFactor(2.5),
        lastReviewedAt: DateTime.now(),
      ),
    );

    if (!_masteredSentences.any((e) => e.id == item.id)) {
      _masteredSentences.add(itemWithSrs);
      _practiceSentences.removeWhere((e) => e.id == item.id);
      _userStats.addXp(10);
      _userStats.totalSentencesLearned++;
      _userStats.updateStreak();

      await _saveData();

      // Sync to Supabase
      if (isSignedIn && currentUserId != null && _selectedLanguage != null) {
        try {
          await _databaseService.saveMasteredSentence(
            userId: currentUserId!,
            languageCode: _selectedLanguage!.code,
            item: itemWithSrs,
          );
        } catch (_) {
          // Sync failed
        }
      }

      _updateDueCountsFromLocal();
      notifyListeners();
    }
  }
}
