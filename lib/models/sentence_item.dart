import 'review_item.dart';

class SentenceItem {
  final String id;
  final String japanese;
  final String romaji;
  final String english;
  final String category;
  String? userNote;

  // SRS fields
  final SrsData srsData;

  SentenceItem({
    required this.id,
    required this.japanese,
    required this.romaji,
    required this.english,
    required this.category,
    this.userNote,
    SrsData? srsData,
  }) : srsData = srsData ?? const SrsData();

  // SRS convenience getters
  DateTime? get nextReviewDate => srsData.nextReviewDate;
  int get reviewInterval => srsData.reviewInterval;
  int get timesReviewed => srsData.timesReviewed;
  double get easeFactor => srsData.easeFactor;
  DateTime? get lastReviewedAt => srsData.lastReviewedAt;
  bool get isDueForReview => srsData.isDueForReview;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'japanese': japanese,
      'romaji': romaji,
      'english': english,
      'category': category,
      'userNote': userNote,
      ...srsData.toJson(),
    };
  }

  factory SentenceItem.fromJson(Map<String, dynamic> json) {
    return SentenceItem(
      id: json['id'],
      japanese: json['japanese'],
      romaji: json['romaji'],
      english: json['english'],
      category: json['category'],
      userNote: json['userNote'],
      srsData: SrsData.fromJson(json),
    );
  }

  SentenceItem copyWith({
    String? id,
    String? japanese,
    String? romaji,
    String? english,
    String? category,
    String? userNote,
    SrsData? srsData,
  }) {
    return SentenceItem(
      id: id ?? this.id,
      japanese: japanese ?? this.japanese,
      romaji: romaji ?? this.romaji,
      english: english ?? this.english,
      category: category ?? this.category,
      userNote: userNote ?? this.userNote,
      srsData: srsData ?? this.srsData,
    );
  }

  /// Create a copy with updated SRS data after review
  SentenceItem withUpdatedSrs({
    required DateTime nextReviewDate,
    required int reviewInterval,
    required double easeFactor,
  }) {
    return copyWith(
      srsData: srsData.copyWith(
        nextReviewDate: nextReviewDate,
        reviewInterval: reviewInterval,
        timesReviewed: srsData.timesReviewed + 1,
        easeFactor: easeFactor,
      ),
    );
  }
}
