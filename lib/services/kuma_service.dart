import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kuma_message.dart';

/// Manages Kuma mascot messages, tutorial state, and visibility settings.
///
/// Singleton with action-based emotion mapping and bilingual messages.
class KumaService {
  static final KumaService _instance = KumaService._internal();
  factory KumaService() => _instance;
  KumaService._internal();

  final _random = Random();

  // ---- Settings keys ----
  static const _keyShowKuma = 'kuma_show';
  static const _keyShowTips = 'kuma_show_tips';
  static const _keyMessageFrequency = 'kuma_message_frequency';
  static const _keyTutorialCompleted = 'kuma_tutorial_completed';

  // ---- Cached prefs ----
  bool _showKuma = true;
  bool _showTips = true;
  int _messageFrequency = 1; // 0=never, 1=rarely, 2=often
  bool _tutorialCompleted = false;
  bool _loaded = false;

  bool get showKuma => _showKuma;
  bool get showTips => _showTips;
  int get messageFrequency => _messageFrequency;
  bool get tutorialCompleted => _tutorialCompleted;

  /// Load prefs once
  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _showKuma = prefs.getBool(_keyShowKuma) ?? true;
    _showTips = prefs.getBool(_keyShowTips) ?? true;
    _messageFrequency = prefs.getInt(_keyMessageFrequency) ?? 1;
    _tutorialCompleted = prefs.getBool(_keyTutorialCompleted) ?? false;
    _loaded = true;
  }

  Future<void> setShowKuma(bool v) async {
    _showKuma = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowKuma, v);
  }

  Future<void> setShowTips(bool v) async {
    _showTips = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowTips, v);
  }

  Future<void> setMessageFrequency(int v) async {
    _messageFrequency = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMessageFrequency, v);
  }

  Future<void> completeTutorial() async {
    _tutorialCompleted = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTutorialCompleted, true);
  }

  Future<void> resetTutorial() async {
    _tutorialCompleted = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTutorialCompleted, false);
  }

  /// Duration between random messages based on frequency setting
  Duration get messageInterval {
    switch (_messageFrequency) {
      case 0:
        return Duration.zero; // never
      case 2:
        return const Duration(seconds: 15);
      default:
        return const Duration(seconds: 30);
    }
  }

  // ---- Action → Emotion mapping ----

  /// Returns the appropriate emotion for a given action.
  KumaEmotion getEmotionForAction(String action) {
    switch (action) {
      case 'correct':
        return KumaEmotion.excited;
      case 'wrong':
        return KumaEmotion.encouraging;
      case 'levelup':
        return KumaEmotion.celebrating;
      case 'streak':
        return KumaEmotion.celebrating;
      case 'idle':
        return _random.nextBool() ? KumaEmotion.happy : KumaEmotion.idle;
      default:
        return KumaEmotion.idle;
    }
  }

  // ---- Message pools (Japanese + English mix) ----

  static const _encouragingMessages = [
    KumaMessage(text: "がんばって! (Ganbatte!) 💪", category: KumaMessageCategory.encouraging, emotion: KumaEmotion.encouraging),
    KumaMessage(text: "You're doing great! ⭐", category: KumaMessageCategory.encouraging, emotion: KumaEmotion.happy),
    KumaMessage(text: "Keep it up! 🔥", category: KumaMessageCategory.encouraging, emotion: KumaEmotion.happy),
    KumaMessage(text: "すごい! (Sugoi!) 🌟", category: KumaMessageCategory.encouraging, emotion: KumaEmotion.excited),
    KumaMessage(text: "やった! (Yatta!) 🎉", category: KumaMessageCategory.encouraging, emotion: KumaEmotion.celebrating),
  ];

  static const _motivationalMessages = [
    KumaMessage(text: "こんにちは! (Konnichiwa!) 🐻", category: KumaMessageCategory.motivational, emotion: KumaEmotion.happy),
    KumaMessage(text: "Ready to learn? 📚", category: KumaMessageCategory.motivational, emotion: KumaEmotion.happy),
    KumaMessage(text: "You got this! 💪", category: KumaMessageCategory.motivational, emotion: KumaEmotion.encouraging),
    KumaMessage(text: "Great job! すごい! ⭐", category: KumaMessageCategory.motivational, emotion: KumaEmotion.excited),
    KumaMessage(text: "Practice makes perfect! 📝", category: KumaMessageCategory.motivational, emotion: KumaEmotion.idle),
    KumaMessage(text: "One word at a time! 🌱", category: KumaMessageCategory.motivational, emotion: KumaEmotion.encouraging),
  ];

  static const _playfulMessages = [
    KumaMessage(text: "Let's learn something new! 🎓", category: KumaMessageCategory.playful, emotion: KumaEmotion.happy),
    KumaMessage(text: "Time flies when we're learning! ⏰", category: KumaMessageCategory.playful, emotion: KumaEmotion.idle),
    KumaMessage(text: "Ready for more? 🚀", category: KumaMessageCategory.playful, emotion: KumaEmotion.excited),
  ];

  static const _allRandomMessages = [
    ..._encouragingMessages,
    ..._motivationalMessages,
    ..._playfulMessages,
  ];

  /// Pick a random message for the home screen
  KumaMessage getRandomMessage() {
    return _allRandomMessages[_random.nextInt(_allRandomMessages.length)];
  }

  // ---- Study reactions ----

  /// Reaction after a correct answer
  KumaMessage getCorrectAnswerReaction() {
    const reactions = [
      KumaMessage(text: "やった! (Yatta!) Perfect! 🎉", category: KumaMessageCategory.reaction, emotion: KumaEmotion.excited),
      KumaMessage(text: "すごい! (Sugoi!) Amazing! 🌟", category: KumaMessageCategory.reaction, emotion: KumaEmotion.excited),
      KumaMessage(text: "素晴らしい! (Subarashii!) ⭐", category: KumaMessageCategory.reaction, emotion: KumaEmotion.excited),
      KumaMessage(text: "Nice one! 🎯", category: KumaMessageCategory.reaction, emotion: KumaEmotion.happy),
      KumaMessage(text: "Perfect! 💯", category: KumaMessageCategory.reaction, emotion: KumaEmotion.excited),
    ];
    return reactions[_random.nextInt(reactions.length)];
  }

  /// Reaction after a wrong answer
  KumaMessage getWrongAnswerReaction() {
    const reactions = [
      KumaMessage(text: "大丈夫! (Daijoubu!) Try again! 💪", category: KumaMessageCategory.reaction, emotion: KumaEmotion.encouraging),
      KumaMessage(text: "頑張って! (Ganbatte!) Don't give up! 🔥", category: KumaMessageCategory.reaction, emotion: KumaEmotion.encouraging),
      KumaMessage(text: "You'll get it next time! 💪", category: KumaMessageCategory.reaction, emotion: KumaEmotion.encouraging),
      KumaMessage(text: "大丈夫! (Daijoubu!) 🐻", category: KumaMessageCategory.reaction, emotion: KumaEmotion.encouraging),
    ];
    return reactions[_random.nextInt(reactions.length)];
  }

  /// Streak milestone reaction
  KumaMessage getStreakReaction(int streak) {
    if (streak >= 5) {
      return const KumaMessage(
        text: "🔥 On fire! すごい!",
        category: KumaMessageCategory.reaction,
        emotion: KumaEmotion.celebrating,
      );
    }
    return KumaMessage(
      text: '$streak day streak! 🔥',
      category: KumaMessageCategory.reaction,
      emotion: KumaEmotion.celebrating,
    );
  }

  /// Session complete reaction
  KumaMessage getSessionCompleteReaction() {
    return const KumaMessage(
      text: 'Great session! やった! 🎉',
      category: KumaMessageCategory.reaction,
      emotion: KumaEmotion.celebrating,
    );
  }

  /// Level up reaction
  KumaMessage getLevelUpReaction(int level) {
    return KumaMessage(
      text: 'Level $level! すごい! 🌟',
      category: KumaMessageCategory.reaction,
      emotion: KumaEmotion.celebrating,
    );
  }

  /// Messages for the first-launch tutorial steps
  List<KumaMessage> get tutorialMessages => const [
        KumaMessage(
          text: "こんにちは! I'm Kuma, your study buddy! 🐻",
          category: KumaMessageCategory.tutorial,
          emotion: KumaEmotion.happy,
        ),
        KumaMessage(
          text: 'Tap a section to study new words!',
          category: KumaMessageCategory.tutorial,
          emotion: KumaEmotion.encouraging,
        ),
        KumaMessage(
          text: 'Your progress is saved in the cloud!',
          category: KumaMessageCategory.tutorial,
          emotion: KumaEmotion.idle,
        ),
        KumaMessage(
          text: "Review words to remember them forever! がんばって! 🔥",
          category: KumaMessageCategory.tutorial,
          emotion: KumaEmotion.celebrating,
        ),
      ];

  /// Welcome screen greeting
  KumaMessage get welcomeMessage => const KumaMessage(
        text: "Let's learn together! 🐻",
        category: KumaMessageCategory.encouraging,
        emotion: KumaEmotion.happy,
      );

  /// Tips dialog content
  List<String> get tips => const [
        'Study a little every day for best results.',
        'Use the "Again" button honestly - it helps the algorithm.',
        'Review due items before learning new ones.',
        'Your streak keeps you motivated!',
        'Tap any mastered word to add a personal note.',
      ];
}
