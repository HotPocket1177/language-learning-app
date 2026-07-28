import 'vocabulary_item.dart';
import 'sentence_item.dart';

/// Languages the app teaches. Bidirectional: a Czech speaker learns English,
/// an English speaker learns Czech.
enum SupportedLanguage {
  english,
  czech;

  String get displayName {
    switch (this) {
      case SupportedLanguage.english:
        return 'English';
      case SupportedLanguage.czech:
        return 'Czech';
    }
  }

  String get nativeName {
    switch (this) {
      case SupportedLanguage.english:
        return 'English';
      case SupportedLanguage.czech:
        return 'Čeština';
    }
  }

  String get flag {
    switch (this) {
      case SupportedLanguage.english:
        return '🇬🇧';
      case SupportedLanguage.czech:
        return '🇨🇿';
    }
  }

  String get code {
    switch (this) {
      case SupportedLanguage.english:
        return 'en';
      case SupportedLanguage.czech:
        return 'cs';
    }
  }

  static SupportedLanguage fromCode(String code) {
    return SupportedLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => SupportedLanguage.english,
    );
  }
}

class LanguageContent {
  final SupportedLanguage language;
  final List<VocabularyItem> vocabulary;
  final List<SentenceItem> sentences;

  LanguageContent({
    required this.language,
    required this.vocabulary,
    required this.sentences,
  });
}
