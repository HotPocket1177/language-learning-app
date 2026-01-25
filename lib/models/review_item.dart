/// Mixin that adds SRS (Spaced Repetition System) fields to study items
mixin SrsFields {
  DateTime? get nextReviewDate;
  int get reviewInterval;
  int get timesReviewed;
  double get easeFactor;
}

/// SRS data that can be attached to any study item
class SrsData {
  final DateTime? nextReviewDate;
  final int reviewInterval;
  final int timesReviewed;
  final double easeFactor;

  const SrsData({
    this.nextReviewDate,
    this.reviewInterval = 1,
    this.timesReviewed = 0,
    this.easeFactor = 2.5,
  });

  factory SrsData.fromJson(Map<String, dynamic> json) {
    return SrsData(
      nextReviewDate: json['next_review_date'] != null
          ? DateTime.parse(json['next_review_date'])
          : null,
      reviewInterval: json['review_interval'] ?? 1,
      timesReviewed: json['times_reviewed'] ?? 0,
      easeFactor: (json['ease_factor'] ?? 2.5).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'next_review_date': nextReviewDate?.toIso8601String().split('T')[0],
      'review_interval': reviewInterval,
      'times_reviewed': timesReviewed,
      'ease_factor': easeFactor,
    };
  }

  SrsData copyWith({
    DateTime? nextReviewDate,
    int? reviewInterval,
    int? timesReviewed,
    double? easeFactor,
  }) {
    return SrsData(
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      reviewInterval: reviewInterval ?? this.reviewInterval,
      timesReviewed: timesReviewed ?? this.timesReviewed,
      easeFactor: easeFactor ?? this.easeFactor,
    );
  }

  /// Check if this item is due for review today or earlier
  bool get isDueForReview {
    if (nextReviewDate == null) return true;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final reviewDate = DateTime(
      nextReviewDate!.year,
      nextReviewDate!.month,
      nextReviewDate!.day,
    );
    return reviewDate.compareTo(todayDate) <= 0;
  }

  /// Days until next review (negative if overdue)
  int get daysUntilReview {
    if (nextReviewDate == null) return 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final reviewDate = DateTime(
      nextReviewDate!.year,
      nextReviewDate!.month,
      nextReviewDate!.day,
    );
    return reviewDate.difference(todayDate).inDays;
  }
}
