import '../data/conversation_data.dart';
import '../utils/romaji_converter.dart';

// Result of processing user input against the conversation tree.
class AiResponse {
  final ConversationNode? nextNode;
  final String? correction; // Gentle correction if input was off
  final bool understood;
  final bool wasEnglish;

  const AiResponse({
    this.nextNode,
    this.correction,
    this.understood = true,
    this.wasEnglish = false,
  });
}

// Hint for the user.
class ConversationHint {
  final String japanese;
  final String romaji;
  final String english;

  const ConversationHint({
    required this.japanese,
    required this.romaji,
    required this.english,
  });
}

/// Keyword-based AI for navigating conversation trees from typed input.
class ConversationAI {
  int correctionsCount = 0;
  int japaneseCharsTyped = 0;

  /// Process user's typed input and find the best matching response.
  AiResponse processInput(String userInput, ConversationNode currentNode) {
    if (userInput.trim().isEmpty) {
      return const AiResponse(understood: false);
    }

    final input = userInput.trim().toLowerCase();

    // Track stats
    japaneseCharsTyped += RomajiConverter.countJapaneseChars(userInput);

    // Check if user typed English
    if (RomajiConverter.isEnglish(input) &&
        !RomajiConverter.containsJapanese(input)) {
      // Try to match English keywords anyway
      final matched = _matchOption(input, currentNode, matchEnglish: true);
      if (matched != null) {
        correctionsCount++;
        return AiResponse(
          nextNode: matched.node,
          correction: 'Try in Japanese: ${matched.option.text}',
          understood: true,
          wasEnglish: true,
        );
      }
      return const AiResponse(
        understood: false,
        wasEnglish: true,
      );
    }

    // Convert romaji to hiragana for matching if needed
    String normalizedInput = input;
    if (RomajiConverter.isRomaji(input)) {
      normalizedInput = RomajiConverter.toHiragana(input);
    }

    // Try matching against options
    final matched = _matchOption(normalizedInput, currentNode);
    if (matched != null) {
      return AiResponse(nextNode: matched.node, understood: true);
    }

    // Try matching original romaji input against option romaji
    final romajiMatched =
        _matchOptionByRomaji(input, currentNode);
    if (romajiMatched != null) {
      return AiResponse(nextNode: romajiMatched.node, understood: true);
    }

    // Partial match — if at least one keyword hits
    final partial = _partialMatch(normalizedInput, input, currentNode);
    if (partial != null) {
      return AiResponse(nextNode: partial.node, understood: true);
    }

    // Not understood
    correctionsCount++;
    return const AiResponse(understood: false);
  }

  _MatchResult? _matchOption(
    String input,
    ConversationNode node, {
    bool matchEnglish = false,
  }) {
    double bestScore = 0;
    _MatchResult? bestMatch;

    for (final option in node.options) {
      double score = 0;

      // Match against Japanese text
      final optJp = option.text.toLowerCase();
      if (input == optJp || input.contains(optJp) || optJp.contains(input)) {
        score = 1.0;
      }

      // Match against English text
      if (matchEnglish) {
        final optEn = option.english.toLowerCase();
        if (input == optEn ||
            input.contains(optEn) ||
            optEn.contains(input)) {
          score = 0.9;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        final nextNode =
            _findNode(option.nextNodeId, node);
        if (nextNode != null) {
          bestMatch = _MatchResult(node: nextNode, option: option);
        }
      }
    }

    return bestScore > 0 ? bestMatch : null;
  }

  _MatchResult? _matchOptionByRomaji(String input, ConversationNode node) {
    for (final option in node.options) {
      final optRomaji = option.romaji.toLowerCase().replaceAll(' ', '');
      final cleanInput = input.replaceAll(' ', '');
      if (cleanInput == optRomaji || optRomaji.contains(cleanInput)) {
        final nextNode = _findNode(option.nextNodeId, node);
        if (nextNode != null) {
          return _MatchResult(node: nextNode, option: option);
        }
      }
    }
    return null;
  }

  _MatchResult? _partialMatch(
      String normalizedInput, String rawInput, ConversationNode node) {
    // Extract keywords from each option and check if any appear in input
    for (final option in node.options) {
      final jpWords = _extractKeywords(option.text);
      final enWords = _extractKeywords(option.english);
      final romajiWords = _extractKeywords(option.romaji);

      int hits = 0;
      for (final kw in jpWords) {
        if (normalizedInput.contains(kw)) hits++;
      }
      for (final kw in romajiWords) {
        if (rawInput.contains(kw)) hits++;
      }
      for (final kw in enWords) {
        if (rawInput.contains(kw)) hits++;
      }

      if (hits > 0) {
        final nextNode = _findNode(option.nextNodeId, node);
        if (nextNode != null) {
          return _MatchResult(node: nextNode, option: option);
        }
      }
    }
    return null;
  }

  List<String> _extractKeywords(String text) {
    // Split on common separators and filter short words
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[!?、。()（）]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 2)
        .toList();
  }

  ConversationNode? _findNode(String nodeId, ConversationNode currentNode) {
    // We need access to the topic's nodes map — store it
    return _topicNodes?[nodeId];
  }

  Map<String, ConversationNode>? _topicNodes;

  /// Set the current topic's node map for lookups.
  void setTopicNodes(Map<String, ConversationNode> nodes) {
    _topicNodes = nodes;
  }

  /// Get hint suggestions based on current node's options.
  List<ConversationHint> getHints(ConversationNode node) {
    return node.options.map((opt) {
      return ConversationHint(
        japanese: opt.text,
        romaji: opt.romaji,
        english: opt.english,
      );
    }).toList();
  }

  /// Get a single suggested response (first option).
  ConversationHint? getSuggestion(ConversationNode node) {
    if (node.options.isEmpty) return null;
    final opt = node.options.first;
    return ConversationHint(
      japanese: opt.text,
      romaji: opt.romaji,
      english: opt.english,
    );
  }

  /// Get "not understood" message from Kuma.
  String getNotUnderstoodMessage(bool wasEnglish) {
    if (wasEnglish) {
      return '日本語で話しましょう! Try in Japanese! 😊';
    }
    return 'ごめんなさい、もう一度お願いします? 🤔\n(Sorry, could you say that again?)';
  }

  /// Calculate accuracy score (0.0 to 1.0).
  double get accuracyScore {
    final totalExchanges = japaneseCharsTyped > 0 ? correctionsCount + 1 : 1;
    return (1.0 - (correctionsCount / totalExchanges)).clamp(0.0, 1.0);
  }

  void reset() {
    correctionsCount = 0;
    japaneseCharsTyped = 0;
    _topicNodes = null;
  }
}

class _MatchResult {
  final ConversationNode node;
  final ResponseOption option;
  const _MatchResult({required this.node, required this.option});
}
