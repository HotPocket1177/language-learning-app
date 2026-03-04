class UserStats {
  String userName;
  int xp;
  int level;
  int currentStreak;
  int longestStreak;
  DateTime? lastStudyDate;
  int totalWordsLearned;
  int totalSentencesLearned;
  int totalKanjiLearned;
  int consecutiveCorrect;
  int bestConsecutiveCorrect;

  UserStats({
    this.userName = 'Student',
    this.xp = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStudyDate,
    this.totalWordsLearned = 0,
    this.totalSentencesLearned = 0,
    this.totalKanjiLearned = 0,
    this.consecutiveCorrect = 0,
    this.bestConsecutiveCorrect = 0,
  });

  int get xpForNextLevel => level * 100;

  int get progressPercent => ((xp % 100) * 100) ~/ xpForNextLevel;

  void addXp(int amount) {
    xp += amount;
    while (xp >= xpForNextLevel) {
      level++;
    }
  }

  void updateStreak() {
    final now = DateTime.now();
    if (lastStudyDate == null) {
      currentStreak = 1;
    } else {
      final difference = now.difference(lastStudyDate!).inDays;
      if (difference == 0) {
        // Same day, do nothing
      } else if (difference == 1) {
        // Next day, increment streak
        currentStreak++;
      } else {
        // Streak broken
        currentStreak = 1;
      }
    }

    // Update longest streak
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    lastStudyDate = now;
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'xp': xp,
      'level': level,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastStudyDate': lastStudyDate?.toIso8601String(),
      'totalWordsLearned': totalWordsLearned,
      'totalSentencesLearned': totalSentencesLearned,
      'totalKanjiLearned': totalKanjiLearned,
      'consecutiveCorrect': consecutiveCorrect,
      'bestConsecutiveCorrect': bestConsecutiveCorrect,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userName: json['userName'] ?? 'Student',
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastStudyDate: json['lastStudyDate'] != null
          ? DateTime.parse(json['lastStudyDate'])
          : null,
      totalWordsLearned: json['totalWordsLearned'] ?? 0,
      totalSentencesLearned: json['totalSentencesLearned'] ?? 0,
      totalKanjiLearned: json['totalKanjiLearned'] ?? 0,
      consecutiveCorrect: json['consecutiveCorrect'] ?? 0,
      bestConsecutiveCorrect: json['bestConsecutiveCorrect'] ?? 0,
    );
  }
}
