import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kuma_message.dart';

/// Manages Kuma mascot messages, tutorial state, and visibility settings
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

  // ---- Message pools ----

  static const _encouragingMessages = [
    KumaMessage(text: "You're making great progress!", category: KumaMessageCategory.encouraging, mood: KumaMood.happy),
    KumaMessage(text: 'Keep up the good work!', category: KumaMessageCategory.encouraging, mood: KumaMood.happy),
    KumaMessage(text: 'Learning is fun!', category: KumaMessageCategory.encouraging, mood: KumaMood.celebrate),
  ];

  static const _motivationalMessages = [
    KumaMessage(text: 'Practice makes perfect!', category: KumaMessageCategory.motivational, mood: KumaMood.wave),
    KumaMessage(text: 'One word at a time!', category: KumaMessageCategory.motivational, mood: KumaMood.idle),
    KumaMessage(text: 'You got this!', category: KumaMessageCategory.motivational, mood: KumaMood.happy),
  ];

  static const _playfulMessages = [
    KumaMessage(text: 'Ready for more?', category: KumaMessageCategory.playful, mood: KumaMood.wave),
    KumaMessage(text: "Let's learn something new!", category: KumaMessageCategory.playful, mood: KumaMood.happy),
    KumaMessage(text: "Time flies when we're learning!", category: KumaMessageCategory.playful, mood: KumaMood.idle),
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

  /// Reaction after a correct answer
  KumaMessage getCorrectAnswerReaction() {
    const reactions = [
      KumaMessage(text: 'Good job!', category: KumaMessageCategory.reaction, mood: KumaMood.happy),
      KumaMessage(text: 'Nice one!', category: KumaMessageCategory.reaction, mood: KumaMood.celebrate),
      KumaMessage(text: 'Perfect!', category: KumaMessageCategory.reaction, mood: KumaMood.happy),
    ];
    return reactions[_random.nextInt(reactions.length)];
  }

  /// Reaction after a wrong answer
  KumaMessage getWrongAnswerReaction() {
    const reactions = [
      KumaMessage(text: 'Try again!', category: KumaMessageCategory.reaction, mood: KumaMood.wave),
      KumaMessage(text: "Don't give up!", category: KumaMessageCategory.reaction, mood: KumaMood.wave),
      KumaMessage(text: "You'll get it next time!", category: KumaMessageCategory.reaction, mood: KumaMood.sad),
    ];
    return reactions[_random.nextInt(reactions.length)];
  }

  /// Streak milestone reaction
  KumaMessage getStreakReaction(int streak) {
    return KumaMessage(
      text: '$streak day streak!',
      category: KumaMessageCategory.reaction,
      mood: KumaMood.celebrate,
    );
  }

  /// Session complete reaction
  KumaMessage getSessionCompleteReaction() {
    return const KumaMessage(
      text: 'Great session!',
      category: KumaMessageCategory.reaction,
      mood: KumaMood.celebrate,
    );
  }

  /// Messages for the first-launch tutorial steps
  List<KumaMessage> get tutorialMessages => const [
        KumaMessage(
          text: "Hi! I'm Kuma, your study buddy!",
          category: KumaMessageCategory.tutorial,
          mood: KumaMood.wave,
        ),
        KumaMessage(
          text: 'Tap a section to study new words!',
          category: KumaMessageCategory.tutorial,
          mood: KumaMood.happy,
        ),
        KumaMessage(
          text: 'Your progress is saved in the cloud!',
          category: KumaMessageCategory.tutorial,
          mood: KumaMood.idle,
        ),
        KumaMessage(
          text: "Review words to remember them forever! Let's go!",
          category: KumaMessageCategory.tutorial,
          mood: KumaMood.celebrate,
        ),
      ];

  /// Welcome screen greeting
  KumaMessage get welcomeMessage => const KumaMessage(
        text: "Let's learn together!",
        category: KumaMessageCategory.encouraging,
        mood: KumaMood.wave,
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
