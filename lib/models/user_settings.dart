/// User settings for Spaced Repetition System (SRS)
class UserSettings {
  final int newWordsPerDay;
  final int reviewWordsPerDay;
  final bool autoAddToPractice;
  final double easyMultiplier;
  final double goodMultiplier;
  final int minInterval;
  final int maxInterval;
  final bool dailyReminderEnabled;
  final String? dailyReminderTime;

  const UserSettings({
    this.newWordsPerDay = 10,
    this.reviewWordsPerDay = 50,
    this.autoAddToPractice = true,
    this.easyMultiplier = 2.5,
    this.goodMultiplier = 1.5,
    this.minInterval = 1,
    this.maxInterval = 365,
    this.dailyReminderEnabled = false,
    this.dailyReminderTime,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      newWordsPerDay: json['new_words_per_day'] ?? 10,
      reviewWordsPerDay: json['review_words_per_day'] ?? 50,
      autoAddToPractice: json['auto_add_to_practice'] ?? true,
      easyMultiplier: (json['easy_multiplier'] ?? 2.5).toDouble(),
      goodMultiplier: (json['good_multiplier'] ?? 1.5).toDouble(),
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
      'good_multiplier': goodMultiplier,
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
    double? goodMultiplier,
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
      goodMultiplier: goodMultiplier ?? this.goodMultiplier,
      minInterval: minInterval ?? this.minInterval,
      maxInterval: maxInterval ?? this.maxInterval,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
    );
  }
}

/// Review difficulty levels for SRS algorithm
enum ReviewDifficulty {
  again,
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
    int nextInterval;
    switch (this) {
      case ReviewDifficulty.again:
        // Reset to minimum interval (1 day by default)
        nextInterval = settings.minInterval;
        break;
      case ReviewDifficulty.good:
        nextInterval = (currentInterval * settings.goodMultiplier).round();
        break;
      case ReviewDifficulty.easy:
        nextInterval = (currentInterval * settings.easyMultiplier).round();
        break;
    }

    return nextInterval.clamp(settings.minInterval, settings.maxInterval);
  }

  /// Adjust ease factor based on difficulty
  double adjustEaseFactor(double currentFactor) {
    switch (this) {
      case ReviewDifficulty.again:
        return (currentFactor - 0.2).clamp(1.3, 3.0);
      case ReviewDifficulty.good:
        return currentFactor;
      case ReviewDifficulty.easy:
        return (currentFactor + 0.15).clamp(1.3, 3.0);
    }
  }

  /// Display label for the button
  String get label {
    switch (this) {
      case ReviewDifficulty.again:
        return 'Again';
      case ReviewDifficulty.good:
        return 'Good';
      case ReviewDifficulty.easy:
        return 'Easy';
    }
  }
}
