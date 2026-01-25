/// User settings for Spaced Repetition System (SRS)
class UserSettings {
  final int newWordsPerDay;
  final int reviewWordsPerDay;
  final bool autoAddToPractice;
  final double easyMultiplier;
  final double hardMultiplier;
  final int minInterval;
  final int maxInterval;
  final bool dailyReminderEnabled;
  final String? dailyReminderTime;

  const UserSettings({
    this.newWordsPerDay = 10,
    this.reviewWordsPerDay = 20,
    this.autoAddToPractice = true,
    this.easyMultiplier = 2.5,
    this.hardMultiplier = 1.2,
    this.minInterval = 1,
    this.maxInterval = 365,
    this.dailyReminderEnabled = false,
    this.dailyReminderTime,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      newWordsPerDay: json['new_words_per_day'] ?? 10,
      reviewWordsPerDay: json['review_words_per_day'] ?? 20,
      autoAddToPractice: json['auto_add_to_practice'] ?? true,
      easyMultiplier: (json['easy_multiplier'] ?? 2.5).toDouble(),
      hardMultiplier: (json['hard_multiplier'] ?? 1.2).toDouble(),
      minInterval: json['min_interval'] ?? 1,
      maxInterval: json['max_interval'] ?? 365,
      dailyReminderEnabled: json['daily_reminder_enabled'] ?? false,
      dailyReminderTime: json['daily_reminder_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'new_words_per_day': newWordsPerDay,
      'review_words_per_day': reviewWordsPerDay,
      'auto_add_to_practice': autoAddToPractice,
      'easy_multiplier': easyMultiplier,
      'hard_multiplier': hardMultiplier,
      'min_interval': minInterval,
      'max_interval': maxInterval,
      'daily_reminder_enabled': dailyReminderEnabled,
      'daily_reminder_time': dailyReminderTime,
    };
  }

  UserSettings copyWith({
    int? newWordsPerDay,
    int? reviewWordsPerDay,
    bool? autoAddToPractice,
    double? easyMultiplier,
    double? hardMultiplier,
    int? minInterval,
    int? maxInterval,
    bool? dailyReminderEnabled,
    String? dailyReminderTime,
  }) {
    return UserSettings(
      newWordsPerDay: newWordsPerDay ?? this.newWordsPerDay,
      reviewWordsPerDay: reviewWordsPerDay ?? this.reviewWordsPerDay,
      autoAddToPractice: autoAddToPractice ?? this.autoAddToPractice,
      easyMultiplier: easyMultiplier ?? this.easyMultiplier,
      hardMultiplier: hardMultiplier ?? this.hardMultiplier,
      minInterval: minInterval ?? this.minInterval,
      maxInterval: maxInterval ?? this.maxInterval,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
    );
  }
}

/// Review difficulty levels for SRS algorithm
enum ReviewDifficulty {
  hard,
  good,
  easy,
}

/// Extension to calculate next interval based on difficulty
extension ReviewDifficultyExtension on ReviewDifficulty {
  /// Calculate next review interval based on current interval and difficulty
  int calculateNextInterval({
    required int currentInterval,
    required double easeFactor,
    required UserSettings settings,
  }) {
    double multiplier;
    switch (this) {
      case ReviewDifficulty.hard:
        multiplier = settings.hardMultiplier;
        break;
      case ReviewDifficulty.good:
        multiplier = easeFactor;
        break;
      case ReviewDifficulty.easy:
        multiplier = settings.easyMultiplier;
        break;
    }

    int nextInterval = (currentInterval * multiplier).round();

    // Clamp to min/max
    if (nextInterval < settings.minInterval) {
      nextInterval = settings.minInterval;
    }
    if (nextInterval > settings.maxInterval) {
      nextInterval = settings.maxInterval;
    }

    return nextInterval;
  }

  /// Adjust ease factor based on difficulty
  double adjustEaseFactor(double currentFactor) {
    switch (this) {
      case ReviewDifficulty.hard:
        // Decrease ease factor (harder = more frequent reviews)
        return (currentFactor - 0.2).clamp(1.3, 3.0);
      case ReviewDifficulty.good:
        // Keep same
        return currentFactor;
      case ReviewDifficulty.easy:
        // Increase ease factor
        return (currentFactor + 0.15).clamp(1.3, 3.0);
    }
  }
}
