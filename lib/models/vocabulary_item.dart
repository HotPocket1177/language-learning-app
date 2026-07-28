import 'review_item.dart';

/// A single vocabulary word in the language being learned.
///
/// Fields are language-neutral so the same model works in both directions
/// (learning English or learning Czech):
///  - [term]:        the word in the language you're studying
///  - [pronunciation]: how to say it (phonetic hint; may be empty)
///  - [translation]: its meaning in your own language
class VocabularyItem {
  final String id;
  final String term;
  final String pronunciation;
  final String translation;
  final String category;
  String? userNote;

  // SRS fields
  final SrsData srsData;

  VocabularyItem({
    required this.id,
    required this.term,
    this.pronunciation = '',
    required this.translation,
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
      'term': term,
      'pronunciation': pronunciation,
      'translation': translation,
      'category': category,
      'userNote': userNote,
      ...srsData.toJson(),
    };
  }

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      id: json['id'],
      // Tolerate legacy keys from before the Czech/English pivot.
      term: json['term'] ?? json['japanese'] ?? '',
      pronunciation: json['pronunciation'] ?? json['romaji'] ?? '',
      translation: json['translation'] ?? json['english'] ?? '',
      category: json['category'],
      userNote: json['userNote'],
      srsData: SrsData.fromJson(json),
    );
  }

  VocabularyItem copyWith({
    String? id,
    String? term,
    String? pronunciation,
    String? translation,
    String? category,
    String? userNote,
    SrsData? srsData,
  }) {
    return VocabularyItem(
      id: id ?? this.id,
      term: term ?? this.term,
      pronunciation: pronunciation ?? this.pronunciation,
      translation: translation ?? this.translation,
      category: category ?? this.category,
      userNote: userNote ?? this.userNote,
      srsData: srsData ?? this.srsData,
    );
  }

  /// Create a copy with updated SRS data after review
  VocabularyItem withUpdatedSrs({
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
