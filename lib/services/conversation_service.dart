import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/conversation_data.dart';

// Persisted message for history
class ConversationMessage {
  final String speaker; // 'kuma' or 'user'
  final String text;
  final String romaji;
  final String english;
  final DateTime timestamp;

  const ConversationMessage({
    required this.speaker,
    required this.text,
    required this.romaji,
    required this.english,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'speaker': speaker,
        'text': text,
        'romaji': romaji,
        'english': english,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ConversationMessage.fromJson(Map<String, dynamic> json) =>
      ConversationMessage(
        speaker: json['speaker'] as String,
        text: json['text'] as String,
        romaji: json['romaji'] as String? ?? '',
        english: json['english'] as String? ?? '',
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

// Saved conversation record
class ConversationRecord {
  final String id;
  final String topicId;
  final String topicEmoji;
  final String topicName;
  final List<ConversationMessage> messages;
  final int messageCount;
  final int xpEarned;
  final bool completed;
  final DateTime createdAt;

  const ConversationRecord({
    required this.id,
    required this.topicId,
    required this.topicEmoji,
    required this.topicName,
    required this.messages,
    required this.messageCount,
    required this.xpEarned,
    required this.completed,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'topicId': topicId,
        'topicEmoji': topicEmoji,
        'topicName': topicName,
        'messages': messages.map((m) => m.toJson()).toList(),
        'messageCount': messageCount,
        'xpEarned': xpEarned,
        'completed': completed,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ConversationRecord.fromJson(Map<String, dynamic> json) =>
      ConversationRecord(
        id: json['id'] as String,
        topicId: json['topicId'] as String,
        topicEmoji: json['topicEmoji'] as String? ?? '',
        topicName: json['topicName'] as String? ?? '',
        messages: (json['messages'] as List)
            .map((m) =>
                ConversationMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
        messageCount: json['messageCount'] as int? ?? 0,
        xpEarned: json['xpEarned'] as int? ?? 20,
        completed: json['completed'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

/// Manages conversation state, flow, and history persistence.
class ConversationService {
  static const _historyKey = 'conversation_history';
  static const _showTranslationKey = 'conv_show_translation';
  static const _showRomajiKey = 'conv_show_romaji';
  static const int xpPerConversation = 20;

  ConversationTopic? _currentTopic;
  ConversationNode? _currentNode;
  final List<ConversationMessage> _messages = [];
  bool _ended = false;

  // Toggle preferences (cached)
  bool showTranslation = true;
  bool showRomaji = true;

  ConversationTopic? get currentTopic => _currentTopic;
  ConversationNode? get currentNode => _currentNode;
  List<ConversationMessage> get messages => List.unmodifiable(_messages);
  bool get isEnded => _ended;
  int get messageCount => _messages.length;

  /// Load toggle preferences from SharedPreferences.
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    showTranslation = prefs.getBool(_showTranslationKey) ?? true;
    showRomaji = prefs.getBool(_showRomajiKey) ?? true;
  }

  Future<void> setShowTranslation(bool value) async {
    showTranslation = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showTranslationKey, value);
  }

  Future<void> setShowRomaji(bool value) async {
    showRomaji = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showRomajiKey, value);
  }

  /// Start a new conversation with the given topic (tree-based).
  void startConversation(ConversationTopic topic) {
    _currentTopic = topic;
    if (topic.nodes.isNotEmpty) {
      _currentNode = topic.nodes['start'];
      if (_currentNode != null) _addKumaMessage(_currentNode!);
    }
    _messages.clear();
    _ended = false;
  }

  /// Start an adaptive conversation (no tree navigation).
  /// Opening message is handled externally by AdaptiveConversation.
  void startAdaptiveConversation(ConversationTopic topic) {
    _currentTopic = topic;
    _currentNode = null;
    _messages.clear();
    _ended = false;
  }

  /// User selects a response option.
  /// Returns the next Kuma node (after simulated delay).
  ConversationNode? selectResponse(ResponseOption option) {
    // Add user message
    _messages.add(ConversationMessage(
      speaker: 'user',
      text: option.text,
      romaji: option.romaji,
      english: option.english,
      timestamp: DateTime.now(),
    ));

    // Navigate to next node
    final nextNode = _currentTopic?.nodes[option.nextNodeId];
    if (nextNode == null) {
      _ended = true;
      return null;
    }

    _currentNode = nextNode;
    _addKumaMessage(nextNode);

    if (nextNode.isEnd) {
      _ended = true;
    }

    return nextNode;
  }

  void _addKumaMessage(ConversationNode node) {
    _messages.add(ConversationMessage(
      speaker: 'kuma',
      text: node.kumaMessage,
      romaji: node.kumaMessageRomaji,
      english: node.kumaMessageEnglish,
      timestamp: DateTime.now(),
    ));
  }

  /// Add a user-typed message (for typing mode).
  void addTypedMessage({
    required String text,
    required String romaji,
    required String english,
  }) {
    _messages.add(ConversationMessage(
      speaker: 'user',
      text: text,
      romaji: romaji,
      english: english,
      timestamp: DateTime.now(),
    ));
  }

  /// Add a Kuma message directly (for typing mode corrections/responses).
  void addKumaTypedMessage({
    required String text,
    required String romaji,
    required String english,
  }) {
    _messages.add(ConversationMessage(
      speaker: 'kuma',
      text: text,
      romaji: romaji,
      english: english,
      timestamp: DateTime.now(),
    ));
  }

  /// Update the current conversation node (for typing mode navigation).
  void updateCurrentNode(ConversationNode node) {
    _currentNode = node;
  }

  /// Mark the conversation as ended.
  void markEnded() {
    _ended = true;
  }

  /// Save completed conversation to local history.
  Future<void> saveToHistory() async {
    if (_currentTopic == null) return;
    final record = ConversationRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      topicId: _currentTopic!.id,
      topicEmoji: _currentTopic!.emoji,
      topicName: _currentTopic!.name,
      messages: List.from(_messages),
      messageCount: _messages.length,
      xpEarned: xpPerConversation,
      completed: _ended,
      createdAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);
    final List<dynamic> history =
        historyJson != null ? json.decode(historyJson) as List : [];
    history.insert(0, record.toJson());
    // Keep last 50 conversations
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
    await prefs.setString(_historyKey, json.encode(history));
  }

  /// Load conversation history from local storage.
  Future<List<ConversationRecord>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);
    if (historyJson == null) return [];
    final List<dynamic> history = json.decode(historyJson) as List;
    return history
        .map((h) => ConversationRecord.fromJson(h as Map<String, dynamic>))
        .toList();
  }

  /// Clear all conversation history.
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  /// Reset state for a new conversation.
  void reset() {
    _currentTopic = null;
    _currentNode = null;
    _messages.clear();
    _ended = false;
  }
}
