class VocabularyItem {
  final String id;
  final String japanese;
  final String romaji;
  final String english;
  final String category;
  String? userNote;

  VocabularyItem({
    required this.id,
    required this.japanese,
    required this.romaji,
    required this.english,
    required this.category,
    this.userNote,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'japanese': japanese,
      'romaji': romaji,
      'english': english,
      'category': category,
      'userNote': userNote,
    };
  }

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      id: json['id'],
      japanese: json['japanese'],
      romaji: json['romaji'],
      english: json['english'],
      category: json['category'],
      userNote: json['userNote'],
    );
  }

  VocabularyItem copyWith({
    String? id,
    String? japanese,
    String? romaji,
    String? english,
    String? category,
    String? userNote,
  }) {
    return VocabularyItem(
      id: id ?? this.id,
      japanese: japanese ?? this.japanese,
      romaji: romaji ?? this.romaji,
      english: english ?? this.english,
      category: category ?? this.category,
      userNote: userNote ?? this.userNote,
    );
  }
}
