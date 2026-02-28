// Conversation topic definitions for practicing Japanese with Kuma-san.
// The adaptive conversation engine (adaptive_conversation.dart) handles
// actual response generation — these are just topic metadata for selection.

class ConversationNode {
  final String id;
  final String kumaMessage;
  final String kumaMessageRomaji;
  final String kumaMessageEnglish;
  final List<ResponseOption> options;
  final bool isEnd;

  const ConversationNode({
    required this.id,
    required this.kumaMessage,
    required this.kumaMessageRomaji,
    required this.kumaMessageEnglish,
    this.options = const [],
    this.isEnd = false,
  });
}

class ResponseOption {
  final String text;
  final String romaji;
  final String english;
  final String nextNodeId;

  const ResponseOption({
    required this.text,
    required this.romaji,
    required this.english,
    required this.nextNodeId,
  });
}

class ConversationTopic {
  final String id;
  final String emoji;
  final String name;
  final String subtitle;
  final int difficulty; // 1-3 stars
  final Map<String, ConversationNode> nodes;

  const ConversationTopic({
    required this.id,
    required this.emoji,
    required this.name,
    required this.subtitle,
    this.difficulty = 1,
    this.nodes = const {},
  });
}

// ============================================
// TOPIC DEFINITIONS
// ============================================

final List<ConversationTopic> conversationTopics = [
  const ConversationTopic(
    id: 'food',
    emoji: '🍜',
    name: 'Food & Restaurants',
    subtitle: 'Practice ordering food',
    difficulty: 1,
  ),
  const ConversationTopic(
    id: 'greetings',
    emoji: '👋',
    name: 'Greetings & Introductions',
    subtitle: 'Practice self-introduction',
    difficulty: 1,
  ),
  const ConversationTopic(
    id: 'daily_life',
    emoji: '🏠',
    name: 'Daily Life',
    subtitle: 'Talk about your day',
    difficulty: 2,
  ),
  const ConversationTopic(
    id: 'shopping',
    emoji: '🛍️',
    name: 'Shopping',
    subtitle: 'Practice buying things',
    difficulty: 2,
  ),
  const ConversationTopic(
    id: 'travel',
    emoji: '🚆',
    name: 'Travel & Directions',
    subtitle: 'Navigate like a pro',
    difficulty: 3,
  ),
  const ConversationTopic(
    id: 'free_talk',
    emoji: '💬',
    name: 'Free Talk',
    subtitle: 'Chat about anything',
    difficulty: 3,
  ),
];
