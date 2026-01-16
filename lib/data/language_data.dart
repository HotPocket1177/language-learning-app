import '../models/vocabulary_item.dart';
import '../models/sentence_item.dart';
import '../models/kanji_item.dart';
import '../models/language_content.dart';

// Japanese Data
final List<VocabularyItem> japaneseVocabulary = [
  VocabularyItem(id: 'ja_v1', japanese: 'こんにちは', romaji: 'konnichiwa', english: 'Hello', category: 'Greetings'),
  VocabularyItem(id: 'ja_v2', japanese: 'おはよう', romaji: 'ohayou', english: 'Good morning', category: 'Greetings'),
  VocabularyItem(id: 'ja_v3', japanese: 'こんばんは', romaji: 'konbanwa', english: 'Good evening', category: 'Greetings'),
  VocabularyItem(id: 'ja_v4', japanese: 'さようなら', romaji: 'sayounara', english: 'Goodbye', category: 'Greetings'),
  VocabularyItem(id: 'ja_v5', japanese: 'ありがとう', romaji: 'arigatou', english: 'Thank you', category: 'Greetings'),
  VocabularyItem(id: 'ja_v6', japanese: 'ごはん', romaji: 'gohan', english: 'Rice/Meal', category: 'Food'),
  VocabularyItem(id: 'ja_v7', japanese: 'みず', romaji: 'mizu', english: 'Water', category: 'Food'),
  VocabularyItem(id: 'ja_v8', japanese: 'さかな', romaji: 'sakana', english: 'Fish', category: 'Food'),
  VocabularyItem(id: 'ja_v9', japanese: 'にく', romaji: 'niku', english: 'Meat', category: 'Food'),
  VocabularyItem(id: 'ja_v10', japanese: 'くだもの', romaji: 'kudamono', english: 'Fruit', category: 'Food'),
  VocabularyItem(id: 'ja_v11', japanese: 'ねこ', romaji: 'neko', english: 'Cat', category: 'Animals'),
  VocabularyItem(id: 'ja_v12', japanese: 'いぬ', romaji: 'inu', english: 'Dog', category: 'Animals'),
  VocabularyItem(id: 'ja_v13', japanese: 'とり', romaji: 'tori', english: 'Bird', category: 'Animals'),
  VocabularyItem(id: 'ja_v14', japanese: 'うさぎ', romaji: 'usagi', english: 'Rabbit', category: 'Animals'),
  VocabularyItem(id: 'ja_v15', japanese: 'たべる', romaji: 'taberu', english: 'To eat', category: 'Verbs'),
  VocabularyItem(id: 'ja_v16', japanese: 'のむ', romaji: 'nomu', english: 'To drink', category: 'Verbs'),
  VocabularyItem(id: 'ja_v17', japanese: 'みる', romaji: 'miru', english: 'To see', category: 'Verbs'),
  VocabularyItem(id: 'ja_v18', japanese: 'いく', romaji: 'iku', english: 'To go', category: 'Verbs'),
  VocabularyItem(id: 'ja_v19', japanese: 'くる', romaji: 'kuru', english: 'To come', category: 'Verbs'),
  VocabularyItem(id: 'ja_v20', japanese: 'すき', romaji: 'suki', english: 'Like/Love', category: 'Adjectives'),
];

final List<SentenceItem> japaneseSentences = [
  SentenceItem(id: 'ja_s1', japanese: 'こんにちは、元気ですか？', romaji: 'Konnichiwa, genki desu ka?', english: 'Hello, how are you?', category: 'Greetings'),
  SentenceItem(id: 'ja_s2', japanese: 'ありがとうございます', romaji: 'Arigatou gozaimasu', english: 'Thank you very much', category: 'Greetings'),
];

// Spanish Data
final List<VocabularyItem> spanishVocabulary = [
  VocabularyItem(id: 'es_v1', japanese: 'hola', romaji: 'hola', english: 'Hello', category: 'Greetings'),
  VocabularyItem(id: 'es_v2', japanese: 'buenos días', romaji: 'buenos días', english: 'Good morning', category: 'Greetings'),
  VocabularyItem(id: 'es_v3', japanese: 'buenas tardes', romaji: 'buenas tardes', english: 'Good afternoon', category: 'Greetings'),
  VocabularyItem(id: 'es_v4', japanese: 'buenas noches', romaji: 'buenas noches', english: 'Good evening', category: 'Greetings'),
  VocabularyItem(id: 'es_v5', japanese: 'adiós', romaji: 'adiós', english: 'Goodbye', category: 'Greetings'),
  VocabularyItem(id: 'es_v6', japanese: 'gracias', romaji: 'gracias', english: 'Thank you', category: 'Greetings'),
  VocabularyItem(id: 'es_v7', japanese: 'por favor', romaji: 'por favor', english: 'Please', category: 'Greetings'),
  VocabularyItem(id: 'es_v8', japanese: 'agua', romaji: 'agua', english: 'Water', category: 'Food'),
  VocabularyItem(id: 'es_v9', japanese: 'pan', romaji: 'pan', english: 'Bread', category: 'Food'),
  VocabularyItem(id: 'es_v10', japanese: 'leche', romaji: 'leche', english: 'Milk', category: 'Food'),
  VocabularyItem(id: 'es_v11', japanese: 'carne', romaji: 'carne', english: 'Meat', category: 'Food'),
  VocabularyItem(id: 'es_v12', japanese: 'pescado', romaji: 'pescado', english: 'Fish', category: 'Food'),
  VocabularyItem(id: 'es_v13', japanese: 'gato', romaji: 'gato', english: 'Cat', category: 'Animals'),
  VocabularyItem(id: 'es_v14', japanese: 'perro', romaji: 'perro', english: 'Dog', category: 'Animals'),
  VocabularyItem(id: 'es_v15', japanese: 'pájaro', romaji: 'pájaro', english: 'Bird', category: 'Animals'),
  VocabularyItem(id: 'es_v16', japanese: 'comer', romaji: 'comer', english: 'To eat', category: 'Verbs'),
  VocabularyItem(id: 'es_v17', japanese: 'beber', romaji: 'beber', english: 'To drink', category: 'Verbs'),
  VocabularyItem(id: 'es_v18', japanese: 'ir', romaji: 'ir', english: 'To go', category: 'Verbs'),
  VocabularyItem(id: 'es_v19', japanese: 'venir', romaji: 'venir', english: 'To come', category: 'Verbs'),
  VocabularyItem(id: 'es_v20', japanese: 'estar', romaji: 'estar', english: 'To be', category: 'Verbs'),
];

final List<SentenceItem> spanishSentences = [
  SentenceItem(id: 'es_s1', japanese: '¿Cómo estás?', romaji: '¿Cómo estás?', english: 'How are you?', category: 'Greetings'),
  SentenceItem(id: 'es_s2', japanese: 'Mucho gusto', romaji: 'Mucho gusto', english: 'Nice to meet you', category: 'Greetings'),
];

// Czech Data
final List<VocabularyItem> czechVocabulary = [
  VocabularyItem(id: 'cs_v1', japanese: 'ahoj', romaji: 'ahoj', english: 'Hello', category: 'Greetings'),
  VocabularyItem(id: 'cs_v2', japanese: 'dobré ráno', romaji: 'dobré ráno', english: 'Good morning', category: 'Greetings'),
  VocabularyItem(id: 'cs_v3', japanese: 'dobrý den', romaji: 'dobrý den', english: 'Good day', category: 'Greetings'),
  VocabularyItem(id: 'cs_v4', japanese: 'dobrý večer', romaji: 'dobrý večer', english: 'Good evening', category: 'Greetings'),
  VocabularyItem(id: 'cs_v5', japanese: 'nashledanou', romaji: 'nashledanou', english: 'Goodbye', category: 'Greetings'),
  VocabularyItem(id: 'cs_v6', japanese: 'děkuji', romaji: 'děkuji', english: 'Thank you', category: 'Greetings'),
  VocabularyItem(id: 'cs_v7', japanese: 'prosím', romaji: 'prosím', english: 'Please', category: 'Greetings'),
  VocabularyItem(id: 'cs_v8', japanese: 'voda', romaji: 'voda', english: 'Water', category: 'Food'),
  VocabularyItem(id: 'cs_v9', japanese: 'chléb', romaji: 'chléb', english: 'Bread', category: 'Food'),
  VocabularyItem(id: 'cs_v10', japanese: 'mléko', romaji: 'mléko', english: 'Milk', category: 'Food'),
  VocabularyItem(id: 'cs_v11', japanese: 'maso', romaji: 'maso', english: 'Meat', category: 'Food'),
  VocabularyItem(id: 'cs_v12', japanese: 'ryba', romaji: 'ryba', english: 'Fish', category: 'Food'),
  VocabularyItem(id: 'cs_v13', japanese: 'kočka', romaji: 'kočka', english: 'Cat', category: 'Animals'),
  VocabularyItem(id: 'cs_v14', japanese: 'pes', romaji: 'pes', english: 'Dog', category: 'Animals'),
  VocabularyItem(id: 'cs_v15', japanese: 'pták', romaji: 'pták', english: 'Bird', category: 'Animals'),
  VocabularyItem(id: 'cs_v16', japanese: 'jíst', romaji: 'jíst', english: 'To eat', category: 'Verbs'),
  VocabularyItem(id: 'cs_v17', japanese: 'pít', romaji: 'pít', english: 'To drink', category: 'Verbs'),
  VocabularyItem(id: 'cs_v18', japanese: 'jít', romaji: 'jít', english: 'To go', category: 'Verbs'),
  VocabularyItem(id: 'cs_v19', japanese: 'přijít', romaji: 'přijít', english: 'To come', category: 'Verbs'),
  VocabularyItem(id: 'cs_v20', japanese: 'být', romaji: 'být', english: 'To be', category: 'Verbs'),
];

final List<SentenceItem> czechSentences = [
  SentenceItem(id: 'cs_s1', japanese: 'Jak se máš?', romaji: 'Jak se máš?', english: 'How are you?', category: 'Greetings'),
  SentenceItem(id: 'cs_s2', japanese: 'Těší mě', romaji: 'Těší mě', english: 'Nice to meet you', category: 'Greetings'),
];

// German Data
final List<VocabularyItem> germanVocabulary = [
  VocabularyItem(id: 'de_v1', japanese: 'hallo', romaji: 'hallo', english: 'Hello', category: 'Greetings'),
  VocabularyItem(id: 'de_v2', japanese: 'guten Morgen', romaji: 'guten Morgen', english: 'Good morning', category: 'Greetings'),
  VocabularyItem(id: 'de_v3', japanese: 'guten Tag', romaji: 'guten Tag', english: 'Good day', category: 'Greetings'),
  VocabularyItem(id: 'de_v4', japanese: 'guten Abend', romaji: 'guten Abend', english: 'Good evening', category: 'Greetings'),
  VocabularyItem(id: 'de_v5', japanese: 'auf Wiedersehen', romaji: 'auf Wiedersehen', english: 'Goodbye', category: 'Greetings'),
  VocabularyItem(id: 'de_v6', japanese: 'danke', romaji: 'danke', english: 'Thank you', category: 'Greetings'),
  VocabularyItem(id: 'de_v7', japanese: 'bitte', romaji: 'bitte', english: 'Please', category: 'Greetings'),
  VocabularyItem(id: 'de_v8', japanese: 'Wasser', romaji: 'Wasser', english: 'Water', category: 'Food'),
  VocabularyItem(id: 'de_v9', japanese: 'Brot', romaji: 'Brot', english: 'Bread', category: 'Food'),
  VocabularyItem(id: 'de_v10', japanese: 'Milch', romaji: 'Milch', english: 'Milk', category: 'Food'),
  VocabularyItem(id: 'de_v11', japanese: 'Fleisch', romaji: 'Fleisch', english: 'Meat', category: 'Food'),
  VocabularyItem(id: 'de_v12', japanese: 'Fisch', romaji: 'Fisch', english: 'Fish', category: 'Food'),
  VocabularyItem(id: 'de_v13', japanese: 'Katze', romaji: 'Katze', english: 'Cat', category: 'Animals'),
  VocabularyItem(id: 'de_v14', japanese: 'Hund', romaji: 'Hund', english: 'Dog', category: 'Animals'),
  VocabularyItem(id: 'de_v15', japanese: 'Vogel', romaji: 'Vogel', english: 'Bird', category: 'Animals'),
  VocabularyItem(id: 'de_v16', japanese: 'essen', romaji: 'essen', english: 'To eat', category: 'Verbs'),
  VocabularyItem(id: 'de_v17', japanese: 'trinken', romaji: 'trinken', english: 'To drink', category: 'Verbs'),
  VocabularyItem(id: 'de_v18', japanese: 'gehen', romaji: 'gehen', english: 'To go', category: 'Verbs'),
  VocabularyItem(id: 'de_v19', japanese: 'kommen', romaji: 'kommen', english: 'To come', category: 'Verbs'),
  VocabularyItem(id: 'de_v20', japanese: 'sein', romaji: 'sein', english: 'To be', category: 'Verbs'),
];

final List<SentenceItem> germanSentences = [
  SentenceItem(id: 'de_s1', japanese: 'Wie geht es dir?', romaji: 'Wie geht es dir?', english: 'How are you?', category: 'Greetings'),
  SentenceItem(id: 'de_s2', japanese: 'Freut mich', romaji: 'Freut mich', english: 'Nice to meet you', category: 'Greetings'),
];

// French Data
final List<VocabularyItem> frenchVocabulary = [
  VocabularyItem(id: 'fr_v1', japanese: 'bonjour', romaji: 'bonjour', english: 'Hello', category: 'Greetings'),
  VocabularyItem(id: 'fr_v2', japanese: 'bonsoir', romaji: 'bonsoir', english: 'Good evening', category: 'Greetings'),
  VocabularyItem(id: 'fr_v3', japanese: 'bonne nuit', romaji: 'bonne nuit', english: 'Good night', category: 'Greetings'),
  VocabularyItem(id: 'fr_v4', japanese: 'au revoir', romaji: 'au revoir', english: 'Goodbye', category: 'Greetings'),
  VocabularyItem(id: 'fr_v5', japanese: 'merci', romaji: 'merci', english: 'Thank you', category: 'Greetings'),
  VocabularyItem(id: 'fr_v6', japanese: "s'il vous plaît", romaji: "s'il vous plaît", english: 'Please', category: 'Greetings'),
  VocabularyItem(id: 'fr_v7', japanese: 'salut', romaji: 'salut', english: 'Hi', category: 'Greetings'),
  VocabularyItem(id: 'fr_v8', japanese: 'eau', romaji: 'eau', english: 'Water', category: 'Food'),
  VocabularyItem(id: 'fr_v9', japanese: 'pain', romaji: 'pain', english: 'Bread', category: 'Food'),
  VocabularyItem(id: 'fr_v10', japanese: 'lait', romaji: 'lait', english: 'Milk', category: 'Food'),
  VocabularyItem(id: 'fr_v11', japanese: 'viande', romaji: 'viande', english: 'Meat', category: 'Food'),
  VocabularyItem(id: 'fr_v12', japanese: 'poisson', romaji: 'poisson', english: 'Fish', category: 'Food'),
  VocabularyItem(id: 'fr_v13', japanese: 'chat', romaji: 'chat', english: 'Cat', category: 'Animals'),
  VocabularyItem(id: 'fr_v14', japanese: 'chien', romaji: 'chien', english: 'Dog', category: 'Animals'),
  VocabularyItem(id: 'fr_v15', japanese: 'oiseau', romaji: 'oiseau', english: 'Bird', category: 'Animals'),
  VocabularyItem(id: 'fr_v16', japanese: 'manger', romaji: 'manger', english: 'To eat', category: 'Verbs'),
  VocabularyItem(id: 'fr_v17', japanese: 'boire', romaji: 'boire', english: 'To drink', category: 'Verbs'),
  VocabularyItem(id: 'fr_v18', japanese: 'aller', romaji: 'aller', english: 'To go', category: 'Verbs'),
  VocabularyItem(id: 'fr_v19', japanese: 'venir', romaji: 'venir', english: 'To come', category: 'Verbs'),
  VocabularyItem(id: 'fr_v20', japanese: 'être', romaji: 'être', english: 'To be', category: 'Verbs'),
];

final List<SentenceItem> frenchSentences = [
  SentenceItem(id: 'fr_s1', japanese: 'Comment allez-vous?', romaji: 'Comment allez-vous?', english: 'How are you?', category: 'Greetings'),
  SentenceItem(id: 'fr_s2', japanese: 'Enchanté', romaji: 'Enchanté', english: 'Nice to meet you', category: 'Greetings'),
];

// Kanji for Japanese only
final List<KanjiItem> japaneseKanji = [
  KanjiItem(id: 'k1', kanji: '日', meaning: 'Sun, day', onyomi: 'ニチ、ジツ', kunyomi: 'ひ、か', examples: ['日本(にほん)', '今日(きょう)'], strokeCount: 4),
  KanjiItem(id: 'k2', kanji: '月', meaning: 'Moon, month', onyomi: 'ゲツ、ガツ', kunyomi: 'つき', examples: ['月曜日(げつようび)', '一月(いちがつ)'], strokeCount: 4),
  KanjiItem(id: 'k3', kanji: '火', meaning: 'Fire', onyomi: 'カ', kunyomi: 'ひ', examples: ['火曜日(かようび)', '火事(かじ)'], strokeCount: 4),
];

// Language Content Map
final Map<SupportedLanguage, LanguageContent> languageContentMap = {
  SupportedLanguage.japanese: LanguageContent(
    language: SupportedLanguage.japanese,
    vocabulary: japaneseVocabulary,
    sentences: japaneseSentences,
    specialContent: japaneseKanji,
  ),
  SupportedLanguage.spanish: LanguageContent(
    language: SupportedLanguage.spanish,
    vocabulary: spanishVocabulary,
    sentences: spanishSentences,
  ),
  SupportedLanguage.czech: LanguageContent(
    language: SupportedLanguage.czech,
    vocabulary: czechVocabulary,
    sentences: czechSentences,
  ),
  SupportedLanguage.german: LanguageContent(
    language: SupportedLanguage.german,
    vocabulary: germanVocabulary,
    sentences: germanSentences,
  ),
  SupportedLanguage.french: LanguageContent(
    language: SupportedLanguage.french,
    vocabulary: frenchVocabulary,
    sentences: frenchSentences,
  ),
};
