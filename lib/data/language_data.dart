import '../models/vocabulary_item.dart';
import '../models/sentence_item.dart';
import '../models/language_content.dart';

// ===========================================================================
// ENGLISH  — for Czech speakers learning English.
//   term = English word · pronunciation = simple phonetic · translation = Czech
// ===========================================================================
final List<VocabularyItem> englishVocabulary = [
  VocabularyItem(id: 'en_v1', term: 'hello', pronunciation: 'he-LOH', translation: 'ahoj / dobrý den', category: 'Greetings'),
  VocabularyItem(id: 'en_v2', term: 'good morning', pronunciation: 'gud MOR-ning', translation: 'dobré ráno', category: 'Greetings'),
  VocabularyItem(id: 'en_v3', term: 'good evening', pronunciation: 'gud EEV-ning', translation: 'dobrý večer', category: 'Greetings'),
  VocabularyItem(id: 'en_v4', term: 'goodbye', pronunciation: 'gud-BAI', translation: 'na shledanou', category: 'Greetings'),
  VocabularyItem(id: 'en_v5', term: 'thank you', pronunciation: 'THANK yoo', translation: 'děkuji', category: 'Greetings'),
  VocabularyItem(id: 'en_v6', term: 'please', pronunciation: 'pleez', translation: 'prosím', category: 'Greetings'),
  VocabularyItem(id: 'en_v7', term: 'sorry', pronunciation: 'SOR-ee', translation: 'promiň', category: 'Greetings'),
  VocabularyItem(id: 'en_v8', term: 'water', pronunciation: 'WAW-ter', translation: 'voda', category: 'Food'),
  VocabularyItem(id: 'en_v9', term: 'bread', pronunciation: 'bred', translation: 'chléb', category: 'Food'),
  VocabularyItem(id: 'en_v10', term: 'milk', pronunciation: 'milk', translation: 'mléko', category: 'Food'),
  VocabularyItem(id: 'en_v11', term: 'meat', pronunciation: 'meet', translation: 'maso', category: 'Food'),
  VocabularyItem(id: 'en_v12', term: 'apple', pronunciation: 'AP-ul', translation: 'jablko', category: 'Food'),
  VocabularyItem(id: 'en_v13', term: 'cat', pronunciation: 'kat', translation: 'kočka', category: 'Animals'),
  VocabularyItem(id: 'en_v14', term: 'dog', pronunciation: 'dog', translation: 'pes', category: 'Animals'),
  VocabularyItem(id: 'en_v15', term: 'bird', pronunciation: 'burd', translation: 'pták', category: 'Animals'),
  VocabularyItem(id: 'en_v16', term: 'horse', pronunciation: 'hors', translation: 'kůň', category: 'Animals'),
  VocabularyItem(id: 'en_v17', term: 'to eat', pronunciation: 'too EET', translation: 'jíst', category: 'Verbs'),
  VocabularyItem(id: 'en_v18', term: 'to drink', pronunciation: 'too DRINK', translation: 'pít', category: 'Verbs'),
  VocabularyItem(id: 'en_v19', term: 'to go', pronunciation: 'too GOH', translation: 'jít', category: 'Verbs'),
  VocabularyItem(id: 'en_v20', term: 'to speak', pronunciation: 'too SPEEK', translation: 'mluvit', category: 'Verbs'),
  VocabularyItem(id: 'en_v21', term: 'one', pronunciation: 'wun', translation: 'jedna', category: 'Numbers'),
  VocabularyItem(id: 'en_v22', term: 'two', pronunciation: 'too', translation: 'dva', category: 'Numbers'),
  VocabularyItem(id: 'en_v23', term: 'three', pronunciation: 'three', translation: 'tři', category: 'Numbers'),
  VocabularyItem(id: 'en_v24', term: 'red', pronunciation: 'red', translation: 'červená', category: 'Colors'),
  VocabularyItem(id: 'en_v25', term: 'blue', pronunciation: 'bloo', translation: 'modrá', category: 'Colors'),
];

final List<SentenceItem> englishSentences = [
  SentenceItem(id: 'en_s1', term: 'How are you?', pronunciation: 'how ar yoo', translation: 'Jak se máš?', category: 'Greetings'),
  SentenceItem(id: 'en_s2', term: 'Nice to meet you.', pronunciation: 'nais too meet yoo', translation: 'Těší mě.', category: 'Greetings'),
  SentenceItem(id: 'en_s3', term: 'I would like some water, please.', pronunciation: 'ai wud laik sum WAW-ter pleez', translation: 'Dal bych si vodu, prosím.', category: 'Food'),
  SentenceItem(id: 'en_s4', term: 'Where is the station?', pronunciation: 'wair iz the STAY-shun', translation: 'Kde je nádraží?', category: 'Travel'),
  SentenceItem(id: 'en_s5', term: 'I do not understand.', pronunciation: 'ai doo not un-der-STAND', translation: 'Nerozumím.', category: 'Basics'),
];

// ===========================================================================
// CZECH  — for English speakers learning Czech.
//   term = Czech word · pronunciation = simple phonetic · translation = English
// ===========================================================================
final List<VocabularyItem> czechVocabulary = [
  VocabularyItem(id: 'cs_v1', term: 'ahoj', pronunciation: 'AH-hoy', translation: 'hello (informal)', category: 'Greetings'),
  VocabularyItem(id: 'cs_v2', term: 'dobré ráno', pronunciation: 'DOB-reh RAH-no', translation: 'good morning', category: 'Greetings'),
  VocabularyItem(id: 'cs_v3', term: 'dobrý den', pronunciation: 'DOB-ree den', translation: 'good day (formal)', category: 'Greetings'),
  VocabularyItem(id: 'cs_v4', term: 'dobrý večer', pronunciation: 'DOB-ree VE-cher', translation: 'good evening', category: 'Greetings'),
  VocabularyItem(id: 'cs_v5', term: 'na shledanou', pronunciation: 'nas-KHLE-da-noh', translation: 'goodbye', category: 'Greetings'),
  VocabularyItem(id: 'cs_v6', term: 'děkuji', pronunciation: 'DYE-ku-yi', translation: 'thank you', category: 'Greetings'),
  VocabularyItem(id: 'cs_v7', term: 'prosím', pronunciation: 'PRO-seem', translation: 'please / you\'re welcome', category: 'Greetings'),
  VocabularyItem(id: 'cs_v8', term: 'promiň', pronunciation: 'PRO-min', translation: 'sorry', category: 'Greetings'),
  VocabularyItem(id: 'cs_v9', term: 'voda', pronunciation: 'VO-da', translation: 'water', category: 'Food'),
  VocabularyItem(id: 'cs_v10', term: 'chléb', pronunciation: 'khleb', translation: 'bread', category: 'Food'),
  VocabularyItem(id: 'cs_v11', term: 'mléko', pronunciation: 'MLEH-ko', translation: 'milk', category: 'Food'),
  VocabularyItem(id: 'cs_v12', term: 'maso', pronunciation: 'MA-so', translation: 'meat', category: 'Food'),
  VocabularyItem(id: 'cs_v13', term: 'jablko', pronunciation: 'YA-bl-ko', translation: 'apple', category: 'Food'),
  VocabularyItem(id: 'cs_v14', term: 'kočka', pronunciation: 'KOCH-ka', translation: 'cat', category: 'Animals'),
  VocabularyItem(id: 'cs_v15', term: 'pes', pronunciation: 'pes', translation: 'dog', category: 'Animals'),
  VocabularyItem(id: 'cs_v16', term: 'pták', pronunciation: 'ptahk', translation: 'bird', category: 'Animals'),
  VocabularyItem(id: 'cs_v17', term: 'kůň', pronunciation: 'koon', translation: 'horse', category: 'Animals'),
  VocabularyItem(id: 'cs_v18', term: 'jíst', pronunciation: 'yeest', translation: 'to eat', category: 'Verbs'),
  VocabularyItem(id: 'cs_v19', term: 'pít', pronunciation: 'peet', translation: 'to drink', category: 'Verbs'),
  VocabularyItem(id: 'cs_v20', term: 'jít', pronunciation: 'yeet', translation: 'to go', category: 'Verbs'),
  VocabularyItem(id: 'cs_v21', term: 'mluvit', pronunciation: 'MLU-vit', translation: 'to speak', category: 'Verbs'),
  VocabularyItem(id: 'cs_v22', term: 'jedna', pronunciation: 'YED-na', translation: 'one', category: 'Numbers'),
  VocabularyItem(id: 'cs_v23', term: 'dva', pronunciation: 'dva', translation: 'two', category: 'Numbers'),
  VocabularyItem(id: 'cs_v24', term: 'tři', pronunciation: 'trzhee', translation: 'three', category: 'Numbers'),
  VocabularyItem(id: 'cs_v25', term: 'červená', pronunciation: 'CHER-ve-nah', translation: 'red', category: 'Colors'),
];

final List<SentenceItem> czechSentences = [
  SentenceItem(id: 'cs_s1', term: 'Jak se máš?', pronunciation: 'yak se mahsh', translation: 'How are you?', category: 'Greetings'),
  SentenceItem(id: 'cs_s2', term: 'Těší mě.', pronunciation: 'TYE-shee mye', translation: 'Nice to meet you.', category: 'Greetings'),
  SentenceItem(id: 'cs_s3', term: 'Dal bych si vodu, prosím.', pronunciation: 'dal bikh si VO-du PRO-seem', translation: 'I would like some water, please.', category: 'Food'),
  SentenceItem(id: 'cs_s4', term: 'Kde je nádraží?', pronunciation: 'kde ye NAH-dra-zhee', translation: 'Where is the station?', category: 'Travel'),
  SentenceItem(id: 'cs_s5', term: 'Nerozumím.', pronunciation: 'NE-ro-zu-meem', translation: 'I do not understand.', category: 'Basics'),
];

// Language Content Map
final Map<SupportedLanguage, LanguageContent> languageContentMap = {
  SupportedLanguage.english: LanguageContent(
    language: SupportedLanguage.english,
    vocabulary: englishVocabulary,
    sentences: englishSentences,
  ),
  SupportedLanguage.czech: LanguageContent(
    language: SupportedLanguage.czech,
    vocabulary: czechVocabulary,
    sentences: czechSentences,
  ),
};
