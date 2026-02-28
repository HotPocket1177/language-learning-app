// Vocabulary data for the adaptive conversation engine.
// Entities, triggers, response patterns, and hints per topic.

import 'dart:math';

/// A recognizable entity with trigger keywords.
class VocabEntity {
  final String id;
  final String jp;
  final String romaji;
  final String en;
  final List<String> triggers;

  const VocabEntity(this.id, this.jp, this.romaji, this.en, this.triggers);
}

/// A localized Kuma response (jp text + English translation).
class KumaLine {
  final String jp;
  final String en;
  const KumaLine(this.jp, this.en);
}

/// All data for one conversation topic.
class TopicVocab {
  final KumaLine opening;
  final List<VocabEntity> entities;
  final Map<String, List<KumaLine>> entityResponses; // entity id → specific responses
  final List<String> wantPatternsJp; // patterns with {jp} / {en} placeholders
  final List<String> wantPatternsEn;
  final List<String> likePatternsJp;
  final List<String> likePatternsEn;
  final List<String> dislikePatternsJp;
  final List<String> dislikePatternsEn;
  final List<String> neutralPatternsJp;
  final List<String> neutralPatternsEn;
  final List<String> followUpPatternsJp;
  final List<String> followUpPatternsEn;
  final List<String> agreePatternsJp;
  final List<String> agreePatternsEn;
  final Map<String, KumaLine> combos; // "id1+id2" → response
  final List<KumaLine> fallbacks;
  final List<({String jp, String romaji, String en})> hints;

  const TopicVocab({
    required this.opening,
    required this.entities,
    this.entityResponses = const {},
    required this.wantPatternsJp,
    required this.wantPatternsEn,
    required this.likePatternsJp,
    required this.likePatternsEn,
    required this.dislikePatternsJp,
    required this.dislikePatternsEn,
    required this.neutralPatternsJp,
    required this.neutralPatternsEn,
    required this.followUpPatternsJp,
    required this.followUpPatternsEn,
    required this.agreePatternsJp,
    required this.agreePatternsEn,
    this.combos = const {},
    required this.fallbacks,
    required this.hints,
  });
}

// ======================================================
// FEELING KEYWORDS (shared across all topics)
// ======================================================

const Map<String, List<String>> feelingTriggers = {
  'want': [
    '食べたい', 'tabetai', 'want', 'ほしい', 'hoshii', '行きたい', 'ikitai',
    'したい', 'shitai', '飲みたい', 'nomitai', 'would like', '見たい', 'mitai',
  ],
  'like': [
    '好き', 'suki', 'like', 'love', '大好き', 'daisuki', 'favorite', 'すき',
    'enjoy', 'いい', 'ii', 'nice', 'すごい', 'sugoi', 'awesome', 'amazing',
  ],
  'dislike': [
    '嫌い', 'kirai', 'きらい', 'hate', "don't like", 'dislike', '苦手',
    'nigate', 'not really', 'ちょっと', 'chotto', 'not a fan',
  ],
  'agree': [
    'はい', 'hai', 'yes', 'うん', 'un', 'そう', 'sou', 'そうです', 'exactly',
    'right', 'yeah', 'yep', 'sure', 'of course', 'もちろん', 'mochiron',
    'ええ', 'correct', 'そのとおり',
  ],
  'disagree': [
    'いいえ', 'iie', 'no', 'ううん', 'uun', 'ちがう', 'chigau', 'not',
    'nope', 'different', 'いや', 'iya',
  ],
};

// ======================================================
// FOOD & RESTAURANTS
// ======================================================

final foodVocab = TopicVocab(
  opening: const KumaLine(
    'こんにちは! お腹が空きましたか? 何が食べたいですか? 🍽️',
    'Hello! Are you hungry? What do you want to eat?',
  ),
  entities: const [
    VocabEntity('ramen', 'ラーメン', 'raamen', 'ramen', ['ラーメン', 'ramen', 'らーめん', 'ラメン']),
    VocabEntity('sushi', '寿司', 'sushi', 'sushi', ['寿司', 'sushi', 'すし', 'おすし', 'お寿司']),
    VocabEntity('rice', 'ご飯', 'gohan', 'rice', ['ご飯', 'gohan', 'rice', 'ごはん', 'お米', 'okome']),
    VocabEntity('meat', '肉', 'niku', 'meat', ['肉', 'niku', 'meat', 'にく', 'お肉']),
    VocabEntity('curry', 'カレー', 'karee', 'curry', ['カレー', 'curry', 'karee', 'かれー']),
    VocabEntity('tempura', '天ぷら', 'tenpura', 'tempura', ['天ぷら', 'tempura', 'tenpura', 'てんぷら']),
    VocabEntity('udon', 'うどん', 'udon', 'udon', ['うどん', 'udon']),
    VocabEntity('soba', 'そば', 'soba', 'soba', ['そば', 'soba', '蕎麦']),
    VocabEntity('takoyaki', 'たこ焼き', 'takoyaki', 'takoyaki', ['たこ焼き', 'takoyaki', 'たこやき']),
    VocabEntity('onigiri', 'おにぎり', 'onigiri', 'rice ball', ['おにぎり', 'onigiri', 'rice ball']),
    VocabEntity('miso', '味噌汁', 'misoshiru', 'miso soup', ['味噌汁', 'miso', 'misoshiru', 'みそしる', 'miso soup']),
    VocabEntity('yakitori', '焼き鳥', 'yakitori', 'yakitori', ['焼き鳥', 'yakitori', 'やきとり']),
    VocabEntity('gyudon', '牛丼', 'gyuudon', 'beef bowl', ['牛丼', 'gyudon', 'gyuudon', 'beef bowl']),
    VocabEntity('tonkatsu', 'とんかつ', 'tonkatsu', 'pork cutlet', ['とんかつ', 'tonkatsu', 'pork cutlet']),
    VocabEntity('okonomiyaki', 'お好み焼き', 'okonomiyaki', 'okonomiyaki', ['お好み焼き', 'okonomiyaki']),
    VocabEntity('pizza', 'ピザ', 'piza', 'pizza', ['ピザ', 'pizza', 'piza']),
    VocabEntity('pasta', 'パスタ', 'pasuta', 'pasta', ['パスタ', 'pasta', 'pasuta', 'spaghetti', 'スパゲティ']),
    VocabEntity('hamburger', 'ハンバーガー', 'hanbaagaa', 'hamburger', ['ハンバーガー', 'hamburger', 'burger', 'バーガー']),
    VocabEntity('salad', 'サラダ', 'sarada', 'salad', ['サラダ', 'salad', 'sarada']),
    VocabEntity('cake', 'ケーキ', 'keeki', 'cake', ['ケーキ', 'cake', 'keeki']),
    VocabEntity('ice_cream', 'アイス', 'aisu', 'ice cream', ['アイス', 'ice cream', 'aisu', 'アイスクリーム']),
    VocabEntity('tea', 'お茶', 'ocha', 'tea', ['お茶', 'tea', 'ocha', 'おちゃ', '緑茶', 'green tea']),
    VocabEntity('coffee', 'コーヒー', 'koohii', 'coffee', ['コーヒー', 'coffee', 'koohii']),
    VocabEntity('beer', 'ビール', 'biiru', 'beer', ['ビール', 'beer', 'biiru']),
    VocabEntity('water', '水', 'mizu', 'water', ['水', 'water', 'mizu', 'みず', 'お水']),
    VocabEntity('fish', '魚', 'sakana', 'fish', ['魚', 'fish', 'sakana', 'さかな']),
    VocabEntity('chicken', '鶏肉', 'toriniku', 'chicken', ['鶏肉', 'chicken', 'toriniku', 'チキン']),
    VocabEntity('egg', '卵', 'tamago', 'egg', ['卵', 'egg', 'tamago', 'たまご']),
    VocabEntity('bread', 'パン', 'pan', 'bread', ['パン', 'bread', 'pan', 'ぱん']),
    VocabEntity('noodles', '麺', 'men', 'noodles', ['麺', 'noodles', 'men', 'めん']),
  ],
  entityResponses: const {
    'ramen': [
      KumaLine('どんなラーメンが好きですか? 醤油? 味噌? とんこつ? 🍜', 'What kind of ramen do you like? Soy sauce? Miso? Tonkotsu?'),
      KumaLine('ラーメンは最高ですね! 私もよく食べます! 🍜', 'Ramen is the best! I eat it often too!'),
    ],
    'sushi': [
      KumaLine('お寿司! 何のネタが好きですか? マグロ? サーモン? 🍣', 'Sushi! What toppings do you like? Tuna? Salmon?'),
      KumaLine('回転寿司によく行きますか? 楽しいですよね! 🍣', 'Do you go to conveyor belt sushi often? It\'s fun!'),
    ],
    'meat': [
      KumaLine('お肉! どんな肉が好きですか? 牛肉? 豚肉? 鶏肉? 🥩', 'Meat! What kind? Beef? Pork? Chicken?'),
      KumaLine('焼肉が好きですか? 日本の焼肉は最高です! 🥩', 'Do you like yakiniku? Japanese BBQ is amazing!'),
    ],
    'curry': [
      KumaLine('カレー! 辛いカレーが好きですか? 🍛', 'Curry! Do you like spicy curry?'),
      KumaLine('日本のカレーは少し甘いですね。インドカレーも好きですか? 🍛', 'Japanese curry is a bit sweet. Do you like Indian curry too?'),
    ],
    'rice': [
      KumaLine('ご飯! 日本人の主食ですね! 何と一緒に食べますか? 🍚', 'Rice! The staple food of Japan! What do you eat it with?'),
    ],
    'tea': [
      KumaLine('お茶! 緑茶が好きですか? 抹茶も美味しいですよ! 🍵', 'Tea! Do you like green tea? Matcha is also delicious!'),
    ],
    'coffee': [
      KumaLine('コーヒー! ブラックですか? ミルク入りですか? ☕', 'Coffee! Black? Or with milk?'),
    ],
  },
  wantPatternsJp: const [
    '{jp}が食べたいんですね! いいですね! 🍽️',
    '{jp}! おいしい選択ですね! 😋',
    '{jp}が食べたい! いい趣味ですね! 👍',
  ],
  wantPatternsEn: const [
    'You want {en}! Great choice!',
    '{en}! Delicious choice!',
    'You want {en}! Good taste!',
  ],
  likePatternsJp: const [
    '{jp}が好きなんですね! 私も大好きです! 😊',
    '{jp}! いいですね! 私も好きです!',
    '{jp}が好き! 素晴らしい! ✨',
  ],
  likePatternsEn: const [
    'You like {en}! I love it too!',
    '{en}! Nice! I like it too!',
    'You like {en}! Wonderful!',
  ],
  dislikePatternsJp: const [
    '{jp}は苦手ですか? 大丈夫、他のものを試しましょう!',
    'そうですか、{jp}はちょっと... 他に何が好きですか?',
  ],
  dislikePatternsEn: const [
    '{en} is not for you? That\'s okay, let\'s try something else!',
    'I see, {en} is not your thing... What else do you like?',
  ],
  neutralPatternsJp: const [
    '{jp}ですね! おいしいですよね! 😊',
    '{jp}! いいですね! よく食べますか?',
    'あ、{jp}! 私も好きですよ! 🍽️',
  ],
  neutralPatternsEn: const [
    '{en}! It\'s delicious, right?',
    '{en}! Nice! Do you eat it often?',
    'Oh, {en}! I like it too!',
  ],
  followUpPatternsJp: const [
    '{jp}をよく食べますか?',
    '{jp}はどこで食べますか? レストラン? 家?',
    '{jp}は自分で作りますか?',
    '他に何が好きですか?',
    '一番好きな食べ物は何ですか?',
  ],
  followUpPatternsEn: const [
    'Do you eat {en} often?',
    'Where do you eat {en}? Restaurant? Home?',
    'Do you make {en} yourself?',
    'What else do you like?',
    'What\'s your favorite food?',
  ],
  agreePatternsJp: const [
    'やっぱり! いいですね! 😄',
    'そうですよね! 私もそう思います!',
    'ですよね! 最高ですね! ✨',
  ],
  agreePatternsEn: const [
    'I knew it! That\'s great!',
    'Right? I think so too!',
    'Exactly! It\'s the best!',
  ],
  combos: const {
    'meat+rice': KumaLine('肉とご飯! 最高の組み合わせですね! 🍖🍚 焼肉丼みたいですか?', 'Meat and rice! Perfect combo! Like a yakiniku bowl?'),
    'rice+meat': KumaLine('肉とご飯! 最高の組み合わせですね! 🍖🍚 焼肉丼みたいですか?', 'Meat and rice! Perfect combo! Like a yakiniku bowl?'),
    'sushi+ramen': KumaLine('寿司とラーメン! 両方食べたいんですね! 😄 どっちが先ですか?', 'Sushi and ramen! You want both! Which first?'),
    'ramen+sushi': KumaLine('ラーメンと寿司! どちらも最高! 😄', 'Ramen and sushi! Both are amazing!'),
    'tea+cake': KumaLine('お茶とケーキ! 素敵な組み合わせ! 🍵🍰', 'Tea and cake! Lovely combination!'),
    'cake+tea': KumaLine('ケーキとお茶! 午後のティータイムですね! 🍰🍵', 'Cake and tea! Afternoon tea time!'),
    'coffee+cake': KumaLine('コーヒーとケーキ! カフェみたいですね! ☕🍰', 'Coffee and cake! Like a café!'),
    'rice+fish': KumaLine('ご飯と魚! 日本の朝ご飯みたいですね! 🍚🐟', 'Rice and fish! Like a Japanese breakfast!'),
    'fish+rice': KumaLine('魚とご飯! 日本の定食ですね! 🐟🍚', 'Fish and rice! A Japanese set meal!'),
    'meat+beer': KumaLine('肉とビール! 最高の組み合わせ! 🍖🍺', 'Meat and beer! The ultimate combo!'),
  },
  fallbacks: const [
    KumaLine('面白いですね! もっと教えてください! 😊', 'Interesting! Tell me more!'),
    KumaLine('そうなんですね! 他に好きな食べ物はありますか?', 'I see! Any other foods you like?'),
    KumaLine('なるほど! 食べ物の話は楽しいですね! 🍽️', 'I see! Talking about food is fun!'),
    KumaLine('分かりました! 何か食べたいものはありますか? 😊', 'Got it! Is there anything you want to eat?'),
  ],
  hints: const [
    (jp: 'ラーメンが食べたいです', romaji: 'Raamen ga tabetai desu', en: 'I want to eat ramen'),
    (jp: '寿司が好きです', romaji: 'Sushi ga suki desu', en: 'I like sushi'),
    (jp: 'カレーをお願いします', romaji: 'Karee wo onegai shimasu', en: 'Curry, please'),
    (jp: '何がおすすめですか', romaji: 'Nani ga osusume desu ka', en: 'What do you recommend?'),
    (jp: 'お茶をください', romaji: 'Ocha wo kudasai', en: 'Tea, please'),
  ],
);

// ======================================================
// GREETINGS & INTRODUCTIONS
// ======================================================

final greetingsVocab = TopicVocab(
  opening: const KumaLine(
    'はじめまして! 私はクマです! 🐻 あなたの名前は何ですか?',
    'Nice to meet you! I\'m Kuma! What\'s your name?',
  ),
  entities: const [
    VocabEntity('name', '名前', 'namae', 'name', ['名前', 'namae', 'name', 'なまえ', 'called', 'call me']),
    VocabEntity('japan', '日本', 'nihon', 'Japan', ['日本', 'nihon', 'japan', 'にほん', 'japanese']),
    VocabEntity('america', 'アメリカ', 'amerika', 'America', ['アメリカ', 'america', 'usa', 'us', 'united states']),
    VocabEntity('country', '国', 'kuni', 'country', ['国', 'kuni', 'country', 'from', 'くに']),
    VocabEntity('hobby', '趣味', 'shumi', 'hobby', ['趣味', 'shumi', 'hobby', 'hobbies', 'しゅみ']),
    VocabEntity('student', '学生', 'gakusei', 'student', ['学生', 'gakusei', 'student', 'がくせい', 'study']),
    VocabEntity('work', '仕事', 'shigoto', 'work', ['仕事', 'shigoto', 'work', 'job', 'しごと']),
    VocabEntity('music', '音楽', 'ongaku', 'music', ['音楽', 'ongaku', 'music', 'おんがく']),
    VocabEntity('sport', 'スポーツ', 'supootsu', 'sports', ['スポーツ', 'sport', 'supootsu', 'sports']),
    VocabEntity('reading', '読書', 'dokusho', 'reading', ['読書', 'dokusho', 'reading', 'read', 'books', '本']),
    VocabEntity('games', 'ゲーム', 'geemu', 'games', ['ゲーム', 'geemu', 'game', 'games', 'gaming', 'video game']),
    VocabEntity('anime', 'アニメ', 'anime', 'anime', ['アニメ', 'anime', 'manga', 'マンガ']),
    VocabEntity('cooking', '料理', 'ryouri', 'cooking', ['料理', 'ryouri', 'cooking', 'cook', 'りょうり']),
    VocabEntity('travel', '旅行', 'ryokou', 'travel', ['旅行', 'ryokou', 'travel', 'trip', 'りょこう']),
  ],
  entityResponses: const {
    'name': [
      KumaLine('いい名前ですね! どうぞよろしくお願いします! 😊', 'Nice name! Pleased to meet you!'),
    ],
    'japan': [
      KumaLine('日本! 日本語を勉強していますか? すごいですね! 🇯🇵', 'Japan! Are you studying Japanese? That\'s great!'),
    ],
    'anime': [
      KumaLine('アニメが好きですか! 私も! どんなアニメが好きですか? 📺', 'You like anime! Me too! What anime do you like?'),
    ],
    'games': [
      KumaLine('ゲーム! 楽しいですよね! 日本のゲームをやりますか? 🎮', 'Games! They\'re fun! Do you play Japanese games?'),
    ],
  },
  wantPatternsJp: const ['{jp}をしたいんですね! いいですね! 😊'],
  wantPatternsEn: const ['You want to do {en}! Nice!'],
  likePatternsJp: const ['{jp}が好きなんですね! いい趣味ですね! ✨', '{jp}! 素敵ですね!'],
  likePatternsEn: const ['You like {en}! Great hobby!', '{en}! Lovely!'],
  dislikePatternsJp: const ['そうですか、{jp}はちょっと... 他には?'],
  dislikePatternsEn: const ['I see, {en} isn\'t for you... What else?'],
  neutralPatternsJp: const ['{jp}ですね! もっと教えてください! 😊', 'あ、{jp}! いいですね!'],
  neutralPatternsEn: const ['{en}! Tell me more!', 'Oh, {en}! Nice!'],
  followUpPatternsJp: const ['趣味は何ですか?', 'お仕事は何をしていますか?', 'どこに住んでいますか?', '日本語はどのくらい勉強していますか?'],
  followUpPatternsEn: const ['What are your hobbies?', 'What do you do for work?', 'Where do you live?', 'How long have you been studying Japanese?'],
  agreePatternsJp: const ['いいですね! 😊', 'そうですよね!', 'なるほど!'],
  agreePatternsEn: const ['Nice!', 'Right!', 'I see!'],
  fallbacks: const [
    KumaLine('面白いですね! もっと聞かせてください! 😊', 'Interesting! Tell me more!'),
    KumaLine('そうなんですね! 趣味は何ですか?', 'I see! What are your hobbies?'),
    KumaLine('もっとあなたのことを知りたいです! 😊', 'I want to know more about you!'),
  ],
  hints: const [
    (jp: '私の名前は...です', romaji: 'Watashi no namae wa ... desu', en: 'My name is ...'),
    (jp: '趣味は音楽です', romaji: 'Shumi wa ongaku desu', en: 'My hobby is music'),
    (jp: 'よろしくお願いします', romaji: 'Yoroshiku onegai shimasu', en: 'Pleased to meet you'),
    (jp: '学生です', romaji: 'Gakusei desu', en: 'I\'m a student'),
  ],
);

// ======================================================
// DAILY LIFE
// ======================================================

final dailyLifeVocab = TopicVocab(
  opening: const KumaLine(
    '今日は何をしましたか? 毎日どんな生活ですか? 🏠',
    'What did you do today? What\'s your daily life like?',
  ),
  entities: const [
    VocabEntity('morning', '朝', 'asa', 'morning', ['朝', 'asa', 'morning', 'あさ']),
    VocabEntity('wake_up', '起きる', 'okiru', 'wake up', ['起きる', 'okiru', 'wake up', 'おきる', 'woke up']),
    VocabEntity('breakfast', '朝ご飯', 'asagohan', 'breakfast', ['朝ご飯', 'asagohan', 'breakfast', 'あさごはん']),
    VocabEntity('work', '仕事', 'shigoto', 'work', ['仕事', 'shigoto', 'work', 'しごと', 'job', 'office']),
    VocabEntity('school', '学校', 'gakkou', 'school', ['学校', 'gakkou', 'school', 'がっこう', 'class']),
    VocabEntity('lunch', '昼ご飯', 'hirugohan', 'lunch', ['昼ご飯', 'hirugohan', 'lunch', 'ひるごはん']),
    VocabEntity('evening', '夕方', 'yuugata', 'evening', ['夕方', 'yuugata', 'evening', 'ゆうがた']),
    VocabEntity('dinner', '晩ご飯', 'bangohan', 'dinner', ['晩ご飯', 'bangohan', 'dinner', 'ばんごはん', '夕飯']),
    VocabEntity('sleep', '寝る', 'neru', 'sleep', ['寝る', 'neru', 'sleep', 'ねる', 'bed', 'tired']),
    VocabEntity('exercise', '運動', 'undou', 'exercise', ['運動', 'undou', 'exercise', 'うんどう', 'gym', 'run', 'jog']),
    VocabEntity('cooking', '料理', 'ryouri', 'cooking', ['料理', 'ryouri', 'cook', 'cooking', 'りょうり']),
    VocabEntity('cleaning', '掃除', 'souji', 'cleaning', ['掃除', 'souji', 'clean', 'cleaning', 'そうじ']),
    VocabEntity('studying', '勉強', 'benkyou', 'studying', ['勉強', 'benkyou', 'study', 'studying', 'べんきょう']),
    VocabEntity('tv', 'テレビ', 'terebi', 'TV', ['テレビ', 'terebi', 'tv', 'television', 'netflix', 'youtube']),
    VocabEntity('weekend', '週末', 'shuumatsu', 'weekend', ['週末', 'shuumatsu', 'weekend', 'しゅうまつ', 'saturday', 'sunday']),
  ],
  entityResponses: const {},
  wantPatternsJp: const ['{jp}をしたいんですね! いいですね! 😊'],
  wantPatternsEn: const ['You want to {en}! Nice!'],
  likePatternsJp: const ['{jp}が好きなんですね! いい習慣ですね! 😊'],
  likePatternsEn: const ['You like {en}! Good habit!'],
  dislikePatternsJp: const ['{jp}は大変ですよね。分かります!'],
  dislikePatternsEn: const ['{en} can be tough. I understand!'],
  neutralPatternsJp: const ['{jp}ですね! いつしますか?', 'あ、{jp}! いいですね! 😊'],
  neutralPatternsEn: const ['{en}! When do you do it?', 'Oh, {en}! Nice!'],
  followUpPatternsJp: const ['今日は何をしましたか?', '週末は何をしますか?', '毎朝何時に起きますか?', '夜は何をしますか?'],
  followUpPatternsEn: const ['What did you do today?', 'What do you do on weekends?', 'What time do you wake up?', 'What do you do at night?'],
  agreePatternsJp: const ['ですよね! 😊', 'そうそう! 分かります!'],
  agreePatternsEn: const ['Right!', 'Yeah! I understand!'],
  fallbacks: const [
    KumaLine('面白い一日ですね! もっと教えてください! 😊', 'What an interesting day! Tell me more!'),
    KumaLine('毎日忙しいですか? 😊', 'Are you busy every day?'),
    KumaLine('なるほど! 楽しそうですね!', 'I see! Sounds fun!'),
  ],
  hints: const [
    (jp: '朝ご飯を食べました', romaji: 'Asagohan wo tabemashita', en: 'I ate breakfast'),
    (jp: '仕事に行きます', romaji: 'Shigoto ni ikimasu', en: 'I go to work'),
    (jp: '週末は休みます', romaji: 'Shuumatsu wa yasumimasu', en: 'I rest on weekends'),
    (jp: '毎日勉強します', romaji: 'Mainichi benkyou shimasu', en: 'I study every day'),
  ],
);

// ======================================================
// SHOPPING
// ======================================================

final shoppingVocab = TopicVocab(
  opening: const KumaLine(
    'お買い物に行きましょう! 何を探していますか? 🛍️',
    'Let\'s go shopping! What are you looking for?',
  ),
  entities: const [
    VocabEntity('clothes', '服', 'fuku', 'clothes', ['服', 'fuku', 'clothes', 'clothing', 'ふく']),
    VocabEntity('shoes', '靴', 'kutsu', 'shoes', ['靴', 'kutsu', 'shoes', 'くつ']),
    VocabEntity('bag', 'かばん', 'kaban', 'bag', ['かばん', 'kaban', 'bag', 'バッグ', 'baggu']),
    VocabEntity('hat', '帽子', 'boushi', 'hat', ['帽子', 'boushi', 'hat', 'cap', 'ぼうし']),
    VocabEntity('cheap', '安い', 'yasui', 'cheap', ['安い', 'yasui', 'cheap', 'やすい', 'affordable']),
    VocabEntity('expensive', '高い', 'takai', 'expensive', ['高い', 'takai', 'expensive', 'たかい', 'pricey']),
    VocabEntity('cute', 'かわいい', 'kawaii', 'cute', ['かわいい', 'kawaii', 'cute', 'pretty']),
    VocabEntity('cool', 'かっこいい', 'kakkoii', 'cool', ['かっこいい', 'kakkoii', 'cool', 'stylish']),
    VocabEntity('big', '大きい', 'ookii', 'big', ['大きい', 'ookii', 'big', 'large', 'おおきい']),
    VocabEntity('small', '小さい', 'chiisai', 'small', ['小さい', 'chiisai', 'small', 'ちいさい']),
    VocabEntity('red', '赤', 'aka', 'red', ['赤', 'aka', 'red', 'あか']),
    VocabEntity('blue', '青', 'ao', 'blue', ['青', 'ao', 'blue', 'あお']),
    VocabEntity('black', '黒', 'kuro', 'black', ['黒', 'kuro', 'black', 'くろ']),
    VocabEntity('white', '白', 'shiro', 'white', ['白', 'shiro', 'white', 'しろ']),
  ],
  entityResponses: const {},
  wantPatternsJp: const ['{jp}が欲しいんですね! いいですね! 🛍️'],
  wantPatternsEn: const ['You want {en}! Nice!'],
  likePatternsJp: const ['{jp}が好きなんですね! いい趣味ですね! 😊'],
  likePatternsEn: const ['You like {en}! Great taste!'],
  dislikePatternsJp: const ['{jp}は苦手ですか? 他のものを見ましょう!'],
  dislikePatternsEn: const ['{en} isn\'t for you? Let\'s look at something else!'],
  neutralPatternsJp: const ['{jp}ですね! いいと思います! 😊', 'あ、{jp}! 見てみましょう!'],
  neutralPatternsEn: const ['{en}! I think it\'s nice!', 'Oh, {en}! Let\'s take a look!'],
  followUpPatternsJp: const ['どんな色が好きですか?', 'サイズは大丈夫ですか?', 'プレゼントですか? 自分用ですか?'],
  followUpPatternsEn: const ['What color do you like?', 'Is the size okay?', 'Is it a gift? Or for yourself?'],
  agreePatternsJp: const ['いい選択ですね! 😊', 'それにしましょう!'],
  agreePatternsEn: const ['Good choice!', 'Let\'s go with that!'],
  fallbacks: const [
    KumaLine('お買い物楽しいですね! 何を見ますか? 🛍️', 'Shopping is fun! What shall we look at?'),
    KumaLine('他に何か探していますか?', 'Are you looking for anything else?'),
  ],
  hints: const [
    (jp: 'これはいくらですか', romaji: 'Kore wa ikura desu ka', en: 'How much is this?'),
    (jp: 'もっと安いのはありますか', romaji: 'Motto yasui no wa arimasu ka', en: 'Do you have something cheaper?'),
    (jp: 'かわいいですね', romaji: 'Kawaii desu ne', en: 'It\'s cute!'),
    (jp: '試着してもいいですか', romaji: 'Shichaku shite mo ii desu ka', en: 'May I try it on?'),
  ],
);

// ======================================================
// TRAVEL & DIRECTIONS
// ======================================================

final travelVocab = TopicVocab(
  opening: const KumaLine(
    '旅行に行きましょう! どこに行きたいですか? 🚆',
    'Let\'s go traveling! Where do you want to go?',
  ),
  entities: const [
    VocabEntity('station', '駅', 'eki', 'station', ['駅', 'eki', 'station', 'えき', 'train station']),
    VocabEntity('train', '電車', 'densha', 'train', ['電車', 'densha', 'train', 'でんしゃ']),
    VocabEntity('bus', 'バス', 'basu', 'bus', ['バス', 'basu', 'bus']),
    VocabEntity('taxi', 'タクシー', 'takushii', 'taxi', ['タクシー', 'takushii', 'taxi', 'cab']),
    VocabEntity('hotel', 'ホテル', 'hoteru', 'hotel', ['ホテル', 'hoteru', 'hotel', 'hostel', 'ryokan', '旅館']),
    VocabEntity('airport', '空港', 'kuukou', 'airport', ['空港', 'kuukou', 'airport', 'くうこう', 'fly', 'flight']),
    VocabEntity('temple', 'お寺', 'otera', 'temple', ['お寺', 'otera', 'temple', 'おてら', '寺']),
    VocabEntity('shrine', '神社', 'jinja', 'shrine', ['神社', 'jinja', 'shrine', 'じんじゃ']),
    VocabEntity('park', '公園', 'kouen', 'park', ['公園', 'kouen', 'park', 'こうえん']),
    VocabEntity('restaurant', 'レストラン', 'resutoran', 'restaurant', ['レストラン', 'resutoran', 'restaurant']),
    VocabEntity('conbini', 'コンビニ', 'konbini', 'convenience store', ['コンビニ', 'konbini', 'convenience store', 'konbini', 'combini']),
    VocabEntity('map', '地図', 'chizu', 'map', ['地図', 'chizu', 'map', 'ちず']),
    VocabEntity('ticket', '切符', 'kippu', 'ticket', ['切符', 'kippu', 'ticket', 'きっぷ', 'チケット']),
    VocabEntity('tokyo', '東京', 'toukyou', 'Tokyo', ['東京', 'tokyo', 'toukyou', 'とうきょう']),
    VocabEntity('kyoto', '京都', 'kyouto', 'Kyoto', ['京都', 'kyoto', 'kyouto', 'きょうと']),
    VocabEntity('osaka', '大阪', 'oosaka', 'Osaka', ['大阪', 'osaka', 'oosaka', 'おおさか']),
  ],
  entityResponses: const {
    'tokyo': [KumaLine('東京! いいですね! 渋谷と秋葉原、どっちに行きたいですか? 🗼', 'Tokyo! Nice! Shibuya or Akihabara, which do you want to visit?')],
    'kyoto': [KumaLine('京都! お寺がたくさんありますね! 金閣寺に行きたいですか? ⛩️', 'Kyoto! So many temples! Want to visit Kinkakuji?')],
    'osaka': [KumaLine('大阪! 食べ物が美味しいですよ! たこ焼きを食べましょう! 🐙', 'Osaka! The food is amazing! Let\'s eat takoyaki!')],
  },
  wantPatternsJp: const ['{jp}に行きたいんですね! いいですね! 🚆'],
  wantPatternsEn: const ['You want to go to {en}! Nice!'],
  likePatternsJp: const ['{jp}が好きなんですね! いい場所ですね! 😊'],
  likePatternsEn: const ['You like {en}! Great place!'],
  dislikePatternsJp: const ['{jp}はちょっと... 他の場所はどうですか?'],
  dislikePatternsEn: const ['{en} isn\'t ideal... How about somewhere else?'],
  neutralPatternsJp: const ['{jp}ですね! 行ったことありますか? 🚆'],
  neutralPatternsEn: const ['{en}! Have you been there before?'],
  followUpPatternsJp: const ['日本に行ったことはありますか?', 'どのくらい旅行しますか?', '飛行機と電車、どっちが好きですか?'],
  followUpPatternsEn: const ['Have you been to Japan?', 'How long will you travel?', 'Plane or train, which do you prefer?'],
  agreePatternsJp: const ['いいですね! 行きましょう! 😊', 'そうしましょう!'],
  agreePatternsEn: const ['Great! Let\'s go!', 'Let\'s do that!'],
  fallbacks: const [
    KumaLine('旅行は楽しいですね! どこに行きたいですか? 🌍', 'Travel is fun! Where do you want to go?'),
    KumaLine('日本には素敵な場所がたくさんありますよ! 😊', 'Japan has so many wonderful places!'),
  ],
  hints: const [
    (jp: '東京に行きたいです', romaji: 'Toukyou ni ikitai desu', en: 'I want to go to Tokyo'),
    (jp: '駅はどこですか', romaji: 'Eki wa doko desu ka', en: 'Where is the station?'),
    (jp: '切符をください', romaji: 'Kippu wo kudasai', en: 'A ticket, please'),
    (jp: 'お寺を見たいです', romaji: 'Otera wo mitai desu', en: 'I want to see a temple'),
  ],
);

// ======================================================
// FREE TALK
// ======================================================

final freeTalkVocab = TopicVocab(
  opening: const KumaLine(
    '何でも話しましょう! 最近どうですか? 💬',
    'Let\'s chat about anything! How have you been recently?',
  ),
  entities: const [
    VocabEntity('weather', '天気', 'tenki', 'weather', ['天気', 'tenki', 'weather', 'てんき']),
    VocabEntity('hot', '暑い', 'atsui', 'hot', ['暑い', 'atsui', 'hot', 'あつい', 'warm']),
    VocabEntity('cold', '寒い', 'samui', 'cold', ['寒い', 'samui', 'cold', 'さむい']),
    VocabEntity('rain', '雨', 'ame', 'rain', ['雨', 'ame', 'rain', 'あめ', 'rainy', 'raining']),
    VocabEntity('music', '音楽', 'ongaku', 'music', ['音楽', 'ongaku', 'music', 'おんがく', 'song']),
    VocabEntity('movie', '映画', 'eiga', 'movie', ['映画', 'eiga', 'movie', 'えいが', 'film']),
    VocabEntity('book', '本', 'hon', 'book', ['本', 'hon', 'book', 'ほん', 'reading', 'read']),
    VocabEntity('game', 'ゲーム', 'geemu', 'game', ['ゲーム', 'geemu', 'game', 'gaming', 'video game']),
    VocabEntity('sport', 'スポーツ', 'supootsu', 'sport', ['スポーツ', 'supootsu', 'sport', 'sports', 'soccer', 'baseball']),
    VocabEntity('cat', '猫', 'neko', 'cat', ['猫', 'neko', 'cat', 'ねこ', 'kitty']),
    VocabEntity('dog', '犬', 'inu', 'dog', ['犬', 'inu', 'dog', 'いぬ', 'puppy']),
    VocabEntity('anime', 'アニメ', 'anime', 'anime', ['アニメ', 'anime', 'cartoon']),
    VocabEntity('manga', 'マンガ', 'manga', 'manga', ['マンガ', 'manga', 'まんが', 'comic']),
    VocabEntity('happy', '嬉しい', 'ureshii', 'happy', ['嬉しい', 'ureshii', 'happy', 'うれしい', 'glad']),
    VocabEntity('tired', '疲れた', 'tsukareta', 'tired', ['疲れた', 'tsukareta', 'tired', 'つかれた', 'exhausted']),
    VocabEntity('busy', '忙しい', 'isogashii', 'busy', ['忙しい', 'isogashii', 'busy', 'いそがしい']),
  ],
  entityResponses: const {
    'cat': [KumaLine('猫! かわいいですよね! 猫を飼っていますか? 🐱', 'Cat! So cute! Do you have a cat?')],
    'dog': [KumaLine('犬! いいですね! 犬を飼っていますか? 🐶', 'Dog! Nice! Do you have a dog?')],
    'anime': [KumaLine('アニメ! 私も大好き! 最近何を見ていますか? 📺', 'Anime! I love it too! What are you watching recently?')],
    'tired': [KumaLine('疲れたんですね... 大丈夫ですか? ゆっくり休んでくださいね! 😴', 'You\'re tired... Are you okay? Please take it easy!')],
  },
  wantPatternsJp: const ['{jp}をしたいんですね! いいですね! 😊'],
  wantPatternsEn: const ['You want to {en}! Nice!'],
  likePatternsJp: const ['{jp}が好きなんですね! 私も! 😊', '{jp}! いいですね!'],
  likePatternsEn: const ['You like {en}! Me too!', '{en}! Nice!'],
  dislikePatternsJp: const ['{jp}は苦手ですか? 大丈夫!'],
  dislikePatternsEn: const ['{en} isn\'t your thing? That\'s okay!'],
  neutralPatternsJp: const ['{jp}ですね! いいですね! 😊', 'あ、{jp}! 面白いですね!'],
  neutralPatternsEn: const ['{en}! Nice!', 'Oh, {en}! Interesting!'],
  followUpPatternsJp: const ['最近何か面白いことありましたか?', '何を見ていますか?', 'ペットを飼っていますか?', '休みの日は何をしますか?'],
  followUpPatternsEn: const ['Anything interesting recently?', 'What are you watching?', 'Do you have any pets?', 'What do you do on days off?'],
  agreePatternsJp: const ['ですよね! 😊', 'そうそう!', '分かります!'],
  agreePatternsEn: const ['Right!', 'Yeah!', 'I understand!'],
  fallbacks: const [
    KumaLine('面白いですね! もっと聞かせてください! 😊', 'Interesting! Tell me more!'),
    KumaLine('いいですね! 他には? 💬', 'Nice! What else?'),
    KumaLine('そうなんですか! 楽しそうですね! 😊', 'Really! Sounds fun!'),
  ],
  hints: const [
    (jp: '最近忙しいです', romaji: 'Saikin isogashii desu', en: 'I\'ve been busy recently'),
    (jp: '猫が好きです', romaji: 'Neko ga suki desu', en: 'I like cats'),
    (jp: 'アニメを見ています', romaji: 'Anime wo mite imasu', en: 'I\'m watching anime'),
    (jp: '天気がいいですね', romaji: 'Tenki ga ii desu ne', en: 'The weather is nice'),
  ],
);

// ======================================================
// LOOKUP
// ======================================================

final Map<String, TopicVocab> topicVocabularyMap = {
  'food': foodVocab,
  'greetings': greetingsVocab,
  'daily_life': dailyLifeVocab,
  'shopping': shoppingVocab,
  'travel': travelVocab,
  'free_talk': freeTalkVocab,
};

/// Helper to pick a random item from a list.
T pickRandom<T>(List<T> items) => items[Random().nextInt(items.length)];
