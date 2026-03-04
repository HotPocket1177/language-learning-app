import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../providers/study_provider.dart';

class AchievementService {
  AchievementService._();
  static final AchievementService _instance = AchievementService._();
  factory AchievementService() => _instance;

  Map<String, DateTime> _unlockedMap = {};
  bool _loaded = false;

  // ── All achievement definitions ──────────────────────────────

  static const List<Achievement> allAchievements = [
    // Milestones
    Achievement(
      id: 'first_steps',
      title: 'First Steps',
      titleJp: '第一歩',
      description: 'Complete your first lesson',
      icon: Icons.emoji_people,
      color: Color(0xFF4CAF50),
      category: AchievementCategory.milestone,
    ),
    Achievement(
      id: 'century_club',
      title: 'Century Club',
      titleJp: '百語達成',
      description: 'Master 100 words',
      icon: Icons.military_tech,
      color: Color(0xFFFF9800),
      category: AchievementCategory.milestone,
    ),
    Achievement(
      id: 'polyglot',
      title: 'Polyglot',
      titleJp: '多言語学者',
      description: 'Study 3 or more languages',
      icon: Icons.translate,
      color: Color(0xFF9C27B0),
      category: AchievementCategory.milestone,
    ),
    Achievement(
      id: 'perfectionist',
      title: 'Perfectionist',
      titleJp: '完璧主義者',
      description: 'Get 10 correct answers in a row',
      icon: Icons.verified,
      color: Color(0xFF2196F3),
      category: AchievementCategory.milestone,
    ),

    // Streaks
    Achievement(
      id: 'week_warrior',
      title: 'Week Warrior',
      titleJp: '一週間の戦士',
      description: '7 day study streak',
      icon: Icons.local_fire_department,
      color: Color(0xFFFF5722),
      category: AchievementCategory.streak,
    ),
    Achievement(
      id: 'comeback',
      title: 'Comeback',
      titleJp: '復帰',
      description: 'Return after a 30 day break',
      icon: Icons.replay,
      color: Color(0xFF607D8B),
      category: AchievementCategory.streak,
    ),

    // Time
    Achievement(
      id: 'night_owl',
      title: 'Night Owl',
      titleJp: '夜更かし',
      description: 'Study after 10pm',
      icon: Icons.nightlight_round,
      color: Color(0xFF3F51B5),
      category: AchievementCategory.time,
    ),
    Achievement(
      id: 'early_bird',
      title: 'Early Bird',
      titleJp: '早起き',
      description: 'Study before 8am',
      icon: Icons.wb_sunny,
      color: Color(0xFFFFC107),
      category: AchievementCategory.time,
    ),

    // Hidden
    Achievement(
      id: 'level_10',
      title: 'Double Digits',
      titleJp: '二桁レベル',
      description: 'Reach level 10',
      icon: Icons.stars,
      color: Color(0xFFFFD700),
      category: AchievementCategory.hidden,
      isHidden: true,
    ),
    Achievement(
      id: 'xp_500',
      title: 'XP Hunter',
      titleJp: 'XPハンター',
      description: 'Earn 500 XP',
      icon: Icons.bolt,
      color: Color(0xFFE91E63),
      category: AchievementCategory.hidden,
      isHidden: true,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Monthly Master',
      titleJp: '月間マスター',
      description: '30 day study streak',
      icon: Icons.whatshot,
      color: Color(0xFFFF3D00),
      category: AchievementCategory.hidden,
      isHidden: true,
    ),
    Achievement(
      id: 'words_50',
      title: 'Half Century',
      titleJp: '五十語',
      description: 'Master 50 words',
      icon: Icons.auto_awesome,
      color: Color(0xFF00BCD4),
      category: AchievementCategory.hidden,
      isHidden: true,
    ),
    Achievement(
      id: 'perfectionist_25',
      title: 'Flawless',
      titleJp: '完全無欠',
      description: '25 correct answers in a row',
      icon: Icons.diamond,
      color: Color(0xFF7C4DFF),
      category: AchievementCategory.hidden,
      isHidden: true,
    ),
  ];

  // ── Load / save persistence ──────────────────────────────────

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('unlockedAchievements');
    if (json != null) {
      final Map<String, dynamic> decoded = jsonDecode(json);
      _unlockedMap = decoded.map(
        (k, v) => MapEntry(k, DateTime.parse(v as String)),
      );
    }
    _loaded = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _unlockedMap.map(
      (k, v) => MapEntry(k, v.toIso8601String()),
    );
    await prefs.setString('unlockedAchievements', jsonEncode(encoded));
  }

  // ── Public API ───────────────────────────────────────────────

  bool isUnlocked(String id) => _unlockedMap.containsKey(id);

  DateTime? unlockedAt(String id) => _unlockedMap[id];

  int get unlockedCount => _unlockedMap.length;

  List<UnlockedAchievement> get recentUnlocked {
    final entries = _unlockedMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(4).map((e) {
      final achievement = allAchievements.firstWhere((a) => a.id == e.key);
      return UnlockedAchievement(achievement: achievement, unlockedAt: e.value);
    }).toList();
  }

  /// Check all achievements against current state.
  /// Returns list of **newly** unlocked achievements.
  Future<List<Achievement>> checkAchievements(StudyProvider provider) async {
    await load();

    final newly = <Achievement>[];
    final stats = provider.userStats;
    final totalItems = stats.totalWordsLearned +
        stats.totalSentencesLearned +
        stats.totalKanjiLearned;

    // First Steps
    if (!isUnlocked('first_steps') && totalItems >= 1) {
      newly.add(_unlock('first_steps'));
    }

    // Century Club
    if (!isUnlocked('century_club') && stats.totalWordsLearned >= 100) {
      newly.add(_unlock('century_club'));
    }

    // Half Century (hidden)
    if (!isUnlocked('words_50') && stats.totalWordsLearned >= 50) {
      newly.add(_unlock('words_50'));
    }

    // Week Warrior
    if (!isUnlocked('week_warrior') && stats.currentStreak >= 7) {
      newly.add(_unlock('week_warrior'));
    }

    // Monthly Master (hidden)
    if (!isUnlocked('streak_30') && stats.currentStreak >= 30) {
      newly.add(_unlock('streak_30'));
    }

    // Perfectionist
    if (!isUnlocked('perfectionist') && stats.bestConsecutiveCorrect >= 10) {
      newly.add(_unlock('perfectionist'));
    }

    // Flawless (hidden)
    if (!isUnlocked('perfectionist_25') &&
        stats.bestConsecutiveCorrect >= 25) {
      newly.add(_unlock('perfectionist_25'));
    }

    // Level 10 (hidden)
    if (!isUnlocked('level_10') && stats.level >= 10) {
      newly.add(_unlock('level_10'));
    }

    // XP 500 (hidden)
    if (!isUnlocked('xp_500') && stats.xp >= 500) {
      newly.add(_unlock('xp_500'));
    }

    // Night Owl
    final hour = DateTime.now().hour;
    if (!isUnlocked('night_owl') && hour >= 22) {
      newly.add(_unlock('night_owl'));
    }

    // Early Bird
    if (!isUnlocked('early_bird') && hour < 8) {
      newly.add(_unlock('early_bird'));
    }

    // Comeback - gap > 30 days between previous lastStudyDate and now
    if (!isUnlocked('comeback') && provider.previousStudyGapDays >= 30) {
      newly.add(_unlock('comeback'));
    }

    // Polyglot - 3+ languages studied
    if (!isUnlocked('polyglot') && provider.studiedLanguageCount >= 3) {
      newly.add(_unlock('polyglot'));
    }

    if (newly.isNotEmpty) {
      await _save();
    }

    return newly;
  }

  /// Get progress toward an achievement (0.0 - 1.0) for display.
  double getProgress(String id, StudyProvider provider) {
    if (isUnlocked(id)) return 1.0;
    final stats = provider.userStats;

    switch (id) {
      case 'first_steps':
        final total = stats.totalWordsLearned +
            stats.totalSentencesLearned +
            stats.totalKanjiLearned;
        return total >= 1 ? 1.0 : 0.0;
      case 'century_club':
        return (stats.totalWordsLearned / 100).clamp(0.0, 1.0);
      case 'words_50':
        return (stats.totalWordsLearned / 50).clamp(0.0, 1.0);
      case 'week_warrior':
        return (stats.currentStreak / 7).clamp(0.0, 1.0);
      case 'streak_30':
        return (stats.currentStreak / 30).clamp(0.0, 1.0);
      case 'perfectionist':
        return (stats.bestConsecutiveCorrect / 10).clamp(0.0, 1.0);
      case 'perfectionist_25':
        return (stats.bestConsecutiveCorrect / 25).clamp(0.0, 1.0);
      case 'level_10':
        return (stats.level / 10).clamp(0.0, 1.0);
      case 'xp_500':
        return (stats.xp / 500).clamp(0.0, 1.0);
      case 'polyglot':
        return (provider.studiedLanguageCount / 3).clamp(0.0, 1.0);
      default:
        return 0.0;
    }
  }

  /// Get progress text for display (e.g. "67/100").
  String getProgressText(String id, StudyProvider provider) {
    if (isUnlocked(id)) return 'Unlocked!';
    final stats = provider.userStats;

    switch (id) {
      case 'century_club':
        return '${stats.totalWordsLearned}/100 words';
      case 'words_50':
        return '${stats.totalWordsLearned}/50 words';
      case 'week_warrior':
        return '${stats.currentStreak}/7 days';
      case 'streak_30':
        return '${stats.currentStreak}/30 days';
      case 'perfectionist':
        return '${stats.bestConsecutiveCorrect}/10 in a row';
      case 'perfectionist_25':
        return '${stats.bestConsecutiveCorrect}/25 in a row';
      case 'level_10':
        return 'Level ${stats.level}/10';
      case 'xp_500':
        return '${stats.xp}/500 XP';
      case 'polyglot':
        return '${provider.studiedLanguageCount}/3 languages';
      default:
        return '';
    }
  }

  // ── Private helpers ──────────────────────────────────────────

  Achievement _unlock(String id) {
    _unlockedMap[id] = DateTime.now();
    return allAchievements.firstWhere((a) => a.id == id);
  }
}
