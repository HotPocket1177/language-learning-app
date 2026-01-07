import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vocabulary_item.dart';
import '../models/sentence_item.dart';
import '../models/kanji_item.dart';
import '../models/user_stats.dart';
import '../data/vocabulary_data.dart';
import '../data/sentence_data.dart';
import '../data/kanji_data.dart';

class StudyProvider with ChangeNotifier {
  UserStats _userStats = UserStats();
  List<VocabularyItem> _masteredVocabulary = [];
  List<SentenceItem> _masteredSentences = [];
  List<String> _masteredKanji = [];
  List<VocabularyItem> _practiceVocabulary = [];
  List<SentenceItem> _practiceSentences = [];

  UserStats get userStats => _userStats;
  List<VocabularyItem> get masteredVocabulary => _masteredVocabulary;
  List<SentenceItem> get masteredSentences => _masteredSentences;
  List<String> get masteredKanji => _masteredKanji;
  List<VocabularyItem> get practiceVocabulary => _practiceVocabulary;
  List<SentenceItem> get practiceSentences => _practiceSentences;

  List<VocabularyItem> get availableVocabulary {
    final masteredIds = _masteredVocabulary.map((e) => e.id).toSet();
    final practiceIds = _practiceVocabulary.map((e) => e.id).toSet();
    return vocabularyData
        .where((item) => !masteredIds.contains(item.id) && !practiceIds.contains(item.id))
        .toList();
  }

  List<SentenceItem> get availableSentences {
    final masteredIds = _masteredSentences.map((e) => e.id).toSet();
    final practiceIds = _practiceSentences.map((e) => e.id).toSet();
    return sentenceData
        .where((item) => !masteredIds.contains(item.id) && !practiceIds.contains(item.id))
        .toList();
  }

  List<KanjiItem> get availableKanji {
    return kanjiData
        .where((item) => !_masteredKanji.contains(item.id))
        .toList();
  }

  // Initialize data from SharedPreferences
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load user stats
    final statsJson = prefs.getString('userStats');
    if (statsJson != null) {
      _userStats = UserStats.fromJson(json.decode(statsJson));
    }

    // Load mastered vocabulary
    final vocabJson = prefs.getString('masteredVocabulary');
    if (vocabJson != null) {
      final List<dynamic> decoded = json.decode(vocabJson);
      _masteredVocabulary = decoded.map((e) => VocabularyItem.fromJson(e)).toList();
    }

    // Load mastered sentences
    final sentJson = prefs.getString('masteredSentences');
    if (sentJson != null) {
      final List<dynamic> decoded = json.decode(sentJson);
      _masteredSentences = decoded.map((e) => SentenceItem.fromJson(e)).toList();
    }

    // Load mastered kanji
    final kanjiJson = prefs.getString('masteredKanji');
    if (kanjiJson != null) {
      _masteredKanji = List<String>.from(json.decode(kanjiJson));
    }

    // Load practice vocabulary
    final practiceVocabJson = prefs.getString('practiceVocabulary');
    if (practiceVocabJson != null) {
      final List<dynamic> decoded = json.decode(practiceVocabJson);
      _practiceVocabulary = decoded.map((e) => VocabularyItem.fromJson(e)).toList();
    }

    // Load practice sentences
    final practiceSentJson = prefs.getString('practiceSentences');
    if (practiceSentJson != null) {
      final List<dynamic> decoded = json.decode(practiceSentJson);
      _practiceSentences = decoded.map((e) => SentenceItem.fromJson(e)).toList();
    }

    notifyListeners();
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('userStats', json.encode(_userStats.toJson()));
    await prefs.setString('masteredVocabulary',
        json.encode(_masteredVocabulary.map((e) => e.toJson()).toList()));
    await prefs.setString('masteredSentences',
        json.encode(_masteredSentences.map((e) => e.toJson()).toList()));
    await prefs.setString('masteredKanji', json.encode(_masteredKanji));
    await prefs.setString('practiceVocabulary',
        json.encode(_practiceVocabulary.map((e) => e.toJson()).toList()));
    await prefs.setString('practiceSentences',
        json.encode(_practiceSentences.map((e) => e.toJson()).toList()));
  }

  // Master a vocabulary word
  void masterVocabulary(VocabularyItem item) {
    if (!_masteredVocabulary.any((e) => e.id == item.id)) {
      _masteredVocabulary.add(item);
      _practiceVocabulary.removeWhere((e) => e.id == item.id);
      _userStats.addXp(10);
      _userStats.totalWordsLearned++;
      _userStats.updateStreak();
      _saveData();
      notifyListeners();
    }
  }

  // Master a sentence
  void masterSentence(SentenceItem item) {
    if (!_masteredSentences.any((e) => e.id == item.id)) {
      _masteredSentences.add(item);
      _practiceSentences.removeWhere((e) => e.id == item.id);
      _userStats.addXp(10);
      _userStats.totalSentencesLearned++;
      _userStats.updateStreak();
      _saveData();
      notifyListeners();
    }
  }

  // Master a kanji
  void masterKanji(String kanjiId) {
    if (!_masteredKanji.contains(kanjiId)) {
      _masteredKanji.add(kanjiId);
      _userStats.addXp(10);
      _userStats.totalKanjiLearned++;
      _userStats.updateStreak();
      _saveData();
      notifyListeners();
    }
  }

  // Add vocabulary to practice deck
  void addVocabularyToPractice(VocabularyItem item) {
    if (!_practiceVocabulary.any((e) => e.id == item.id) &&
        !_masteredVocabulary.any((e) => e.id == item.id)) {
      _practiceVocabulary.add(item);
      _saveData();
      notifyListeners();
    }
  }

  // Add sentence to practice deck
  void addSentenceToPractice(SentenceItem item) {
    if (!_practiceSentences.any((e) => e.id == item.id) &&
        !_masteredSentences.any((e) => e.id == item.id)) {
      _practiceSentences.add(item);
      _saveData();
      notifyListeners();
    }
  }

  // Remove from practice deck
  void removeVocabularyFromPractice(String id) {
    _practiceVocabulary.removeWhere((e) => e.id == id);
    _saveData();
    notifyListeners();
  }

  void removeSentenceFromPractice(String id) {
    _practiceSentences.removeWhere((e) => e.id == id);
    _saveData();
    notifyListeners();
  }

  // Update note for vocabulary
  void updateVocabularyNote(String id, String note) {
    final index = _masteredVocabulary.indexWhere((e) => e.id == id);
    if (index != -1) {
      _masteredVocabulary[index] = _masteredVocabulary[index].copyWith(userNote: note);
      _saveData();
      notifyListeners();
    }
  }

  // Update note for sentence
  void updateSentenceNote(String id, String note) {
    final index = _masteredSentences.indexWhere((e) => e.id == id);
    if (index != -1) {
      _masteredSentences[index] = _masteredSentences[index].copyWith(userNote: note);
      _saveData();
      notifyListeners();
    }
  }

  // Update user name
  void updateUserName(String name) {
    _userStats.userName = name;
    _saveData();
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
    return vocabularyData.map((e) => e.category).toSet().toList()..sort();
  }

  List<String> get sentenceCategories {
    return sentenceData.map((e) => e.category).toSet().toList()..sort();
  }
}
