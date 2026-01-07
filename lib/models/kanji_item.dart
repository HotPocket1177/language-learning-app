class KanjiItem {
  final String id;
  final String kanji;
  final String meaning;
  final String onyomi;
  final String kunyomi;
  final List<String> examples;
  final int strokeCount;

  KanjiItem({
    required this.id,
    required this.kanji,
    required this.meaning,
    required this.onyomi,
    required this.kunyomi,
    required this.examples,
    required this.strokeCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kanji': kanji,
      'meaning': meaning,
      'onyomi': onyomi,
      'kunyomi': kunyomi,
      'examples': examples,
      'strokeCount': strokeCount,
    };
  }

  factory KanjiItem.fromJson(Map<String, dynamic> json) {
    return KanjiItem(
      id: json['id'],
      kanji: json['kanji'],
      meaning: json['meaning'],
      onyomi: json['onyomi'],
      kunyomi: json['kunyomi'],
      examples: List<String>.from(json['examples']),
      strokeCount: json['strokeCount'],
    );
  }
}
