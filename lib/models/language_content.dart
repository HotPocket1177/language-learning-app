import 'vocabulary_item.dart';
import 'sentence_item.dart';
import 'kanji_item.dart';

enum SupportedLanguage {
  japanese,
  spanish,
  czech,
  german,
  french;

  String get displayName {
    switch (this) {
      case SupportedLanguage.japanese:
        return 'Japanese';
      case SupportedLanguage.spanish:
        return 'Spanish';
      case SupportedLanguage.czech:
        return 'Czech';
      case SupportedLanguage.german:
        return 'German';
      case SupportedLanguage.french:
        return 'French';
    }
  }

  String get nativeName {
    switch (this) {
      case SupportedLanguage.japanese:
        return '日本語';
      case SupportedLanguage.spanish:
        return 'Español';
      case SupportedLanguage.czech:
        return 'Čeština';
      case SupportedLanguage.german:
        return 'Deutsch';
      case SupportedLanguage.french:
        return 'Français';
    }
  }

  String get flag {
    switch (this) {
      case SupportedLanguage.japanese:
        return '🇯🇵';
      case SupportedLanguage.spanish:
        return '🇪🇸';
      case SupportedLanguage.czech:
        return '🇨🇿';
      case SupportedLanguage.german:
        return '🇩🇪';
      case SupportedLanguage.french:
        return '🇫🇷';
    }
  }

  String get code {
    switch (this) {
      case SupportedLanguage.japanese:
        return 'ja';
      case SupportedLanguage.spanish:
        return 'es';
      case SupportedLanguage.czech:
        return 'cs';
      case SupportedLanguage.german:
        return 'de';
      case SupportedLanguage.french:
        return 'fr';
    }
  }

  bool get hasSpecialContent {
    return this == SupportedLanguage.japanese;
  }

  static SupportedLanguage fromCode(String code) {
    return SupportedLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => SupportedLanguage.japanese,
    );
  }
}

class LanguageContent {
  final SupportedLanguage language;
  final List<VocabularyItem> vocabulary;
  final List<SentenceItem> sentences;
  final List<KanjiItem>? specialContent; // Only for Japanese (Kanji)

  LanguageContent({
    required this.language,
    required this.vocabulary,
    required this.sentences,
    this.specialContent,
  });
}
