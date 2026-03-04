import 'package:flutter/material.dart';

enum AchievementCategory {
  milestone,
  streak,
  mastery,
  time,
  hidden;

  String get displayName {
    switch (this) {
      case AchievementCategory.milestone:
        return 'Milestones';
      case AchievementCategory.streak:
        return 'Streaks';
      case AchievementCategory.mastery:
        return 'Mastery';
      case AchievementCategory.time:
        return 'Time';
      case AchievementCategory.hidden:
        return 'Secret';
    }
  }

  IconData get icon {
    switch (this) {
      case AchievementCategory.milestone:
        return Icons.flag;
      case AchievementCategory.streak:
        return Icons.local_fire_department;
      case AchievementCategory.mastery:
        return Icons.school;
      case AchievementCategory.time:
        return Icons.schedule;
      case AchievementCategory.hidden:
        return Icons.help_outline;
    }
  }
}

class Achievement {
  final String id;
  final String title;
  final String titleJp;
  final String description;
  final IconData icon;
  final Color color;
  final AchievementCategory category;
  final bool isHidden;

  const Achievement({
    required this.id,
    required this.title,
    required this.titleJp,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    this.isHidden = false,
  });
}

class UnlockedAchievement {
  final Achievement achievement;
  final DateTime unlockedAt;

  const UnlockedAchievement({
    required this.achievement,
    required this.unlockedAt,
  });
}
