import 'dart:math';
import '../data/conversation_vocabulary.dart';
import '../utils/romaji_converter.dart';

/// A hint suggestion for the user.
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

/// Result of processing user input.
class AdaptiveResponse {
  final String text;
  final String romaji;
  final String english;
  final bool isEnd;
  const AdaptiveResponse({
    required this.text,
    this.romaji = '',
    this.english = '',
    this.isEnd = false,
  });
}

/// Detected feeling from input.
enum Feeling { want, like, dislike, agree, disagree, neutral }

/// An entity matched from user input.
class _Match {
  final VocabEntity entity;
  const _Match(this.entity);
}

/// Adaptive conversation engine — extracts entities, tracks context,
/// generates responses based on what the user ACTUALLY typed.
class AdaptiveConversation {
  final String topicId;
  final TopicVocab _vocab;
  final Random _rng = Random();

  int _turnCount = 0;
  final List<String> _mentionedEntities = [];
  final Set<int> _usedPatternIndices = {};
  String? _lastEntityId;

  // Stats
  int correctionsCount = 0;
  int japaneseCharsTyped = 0;
  int _totalInputs = 0;

  AdaptiveConversation({required this.topicId})
      : _vocab = topicVocabularyMap[topicId] ?? foodVocab;

  // ==========================================
  // PUBLIC API
  // ==========================================

  /// Get Kuma's opening message for this topic.
  AdaptiveResponse getOpeningMessage() {
    return AdaptiveResponse(
      text: _vocab.opening.jp,
      english: _vocab.opening.en,
    );
  }

  /// Process user's typed input and return Kuma's adaptive response.
  AdaptiveResponse processInput(String userInput) {
    if (userInput.trim().isEmpty) {
      return _fallback();
    }

    _totalInputs++;
    _turnCount++;
    final input = userInput.trim();
    final lower = input.toLowerCase();

    // Track Japanese chars
    japaneseCharsTyped += RomajiConverter.countJapaneseChars(input);

    // Normalize: convert romaji to hiragana for entity matching
    String normalized = lower;
    if (RomajiConverter.isRomaji(lower)) {
      normalized = RomajiConverter.toHiragana(lower);
    }

    // 1. Detect feeling
    final feeling = _detectFeeling(lower);

    // 2. Extract entities
    final matches = _extractEntities(lower, normalized);

    // 3. Check if user typed only in English (no Japanese, no romaji match)
    final isEnglishOnly = RomajiConverter.isEnglish(lower) &&
        !RomajiConverter.containsJapanese(input) &&
        matches.isEmpty;

    // 4. Generate response
    AdaptiveResponse response;

    if (matches.length >= 2) {
      // Multi-entity: check combos first
      response = _handleMultiEntity(matches, feeling);
    } else if (matches.length == 1) {
      // Single entity
      response = _handleSingleEntity(matches.first, feeling);
    } else if (feeling == Feeling.agree || feeling == Feeling.disagree) {
      // No entity but agreement/disagreement
      response = _handleAgreement(feeling);
    } else if (isEnglishOnly) {
      // English-only: gentle suggestion
      correctionsCount++;
      response = _handleEnglishInput(lower);
    } else {
      // Nothing matched — conversational fallback
      response = _fallbackWithFollowUp();
    }

    // 5. Check conversation end
    final isEnd = _turnCount >= 10;

    return AdaptiveResponse(
      text: response.text,
      romaji: response.romaji,
      english: response.english,
      isEnd: isEnd,
    );
  }

  /// Get hint suggestions for the current topic.
  List<ConversationHint> getHints() {
    return _vocab.hints.map((h) => ConversationHint(
          japanese: h.jp,
          romaji: h.romaji,
          english: h.en,
        )).toList();
  }

  /// Get one random suggestion.
  ConversationHint? getSuggestion() {
    if (_vocab.hints.isEmpty) return null;
    final h = pickRandom(_vocab.hints);
    return ConversationHint(japanese: h.jp, romaji: h.romaji, english: h.en);
  }

  /// Accuracy score (0.0 to 1.0).
  double get accuracyScore {
    if (_totalInputs == 0) return 1.0;
    return (1.0 - (correctionsCount / _totalInputs)).clamp(0.0, 1.0);
  }

  void reset() {
    _turnCount = 0;
    _mentionedEntities.clear();
    _usedPatternIndices.clear();
    _lastEntityId = null;
    correctionsCount = 0;
    japaneseCharsTyped = 0;
    _totalInputs = 0;
  }

  // ==========================================
  // ENTITY EXTRACTION
  // ==========================================

  List<_Match> _extractEntities(String lower, String normalized) {
    final found = <_Match>[];
    final seenIds = <String>{};

    for (final entity in _vocab.entities) {
      for (final trigger in entity.triggers) {
        final t = trigger.toLowerCase();
        if (lower.contains(t) || normalized.contains(t)) {
          if (seenIds.add(entity.id)) {
            found.add(_Match(entity));
          }
          break;
        }
      }
    }
    return found;
  }

  // ==========================================
  // FEELING DETECTION
  // ==========================================

  Feeling _detectFeeling(String lower) {
    // Check each feeling's trigger words
    for (final entry in feelingTriggers.entries) {
      for (final trigger in entry.value) {
        if (lower.contains(trigger.toLowerCase())) {
          return _feelingFromString(entry.key);
        }
      }
    }
    return Feeling.neutral;
  }

  Feeling _feelingFromString(String s) {
    switch (s) {
      case 'want': return Feeling.want;
      case 'like': return Feeling.like;
      case 'dislike': return Feeling.dislike;
      case 'agree': return Feeling.agree;
      case 'disagree': return Feeling.disagree;
      default: return Feeling.neutral;
    }
  }

  // ==========================================
  // RESPONSE GENERATION
  // ==========================================

  AdaptiveResponse _handleSingleEntity(_Match match, Feeling feeling) {
    final entity = match.entity;
    _mentionedEntities.add(entity.id);
    _lastEntityId = entity.id;

    // Check for entity-specific responses first
    final specific = _vocab.entityResponses[entity.id];
    if (specific != null && specific.isNotEmpty && _rng.nextDouble() > 0.4) {
      final r = pickRandom(specific);
      return AdaptiveResponse(text: r.jp, english: r.en);
    }

    // Use feeling-based pattern
    String jp;
    String en;

    switch (feeling) {
      case Feeling.want:
        jp = _pickPattern(_vocab.wantPatternsJp, entity);
        en = _pickPattern(_vocab.wantPatternsEn, entity);
      case Feeling.like:
        jp = _pickPattern(_vocab.likePatternsJp, entity);
        en = _pickPattern(_vocab.likePatternsEn, entity);
      case Feeling.dislike:
        jp = _pickPattern(_vocab.dislikePatternsJp, entity);
        en = _pickPattern(_vocab.dislikePatternsEn, entity);
      default:
        jp = _pickPattern(_vocab.neutralPatternsJp, entity);
        en = _pickPattern(_vocab.neutralPatternsEn, entity);
    }

    // Add a follow-up question sometimes (50% chance after turn 2)
    if (_turnCount > 2 && _rng.nextBool()) {
      final fJp = _pickPattern(_vocab.followUpPatternsJp, entity);
      final fEn = _pickPattern(_vocab.followUpPatternsEn, entity);
      jp = '$jp\n$fJp';
      en = '$en\n$fEn';
    }

    return AdaptiveResponse(text: jp, english: en);
  }

  AdaptiveResponse _handleMultiEntity(List<_Match> matches, Feeling feeling) {
    // Remember all entities
    for (final m in matches) {
      _mentionedEntities.add(m.entity.id);
    }
    _lastEntityId = matches.first.entity.id;

    // Check for known combos
    for (int i = 0; i < matches.length; i++) {
      for (int j = i + 1; j < matches.length; j++) {
        final key1 = '${matches[i].entity.id}+${matches[j].entity.id}';
        final key2 = '${matches[j].entity.id}+${matches[i].entity.id}';
        final combo = _vocab.combos[key1] ?? _vocab.combos[key2];
        if (combo != null) {
          return AdaptiveResponse(text: combo.jp, english: combo.en);
        }
      }
    }

    // Generic multi-entity response
    final names = matches.map((m) => m.entity.jp).join('と');
    final namesEn = matches.map((m) => m.entity.en).join(' and ');
    return AdaptiveResponse(
      text: '$namesですね! いい組み合わせ! 😊 もっと教えてください!',
      english: '$namesEn! Great combination! Tell me more!',
    );
  }

  AdaptiveResponse _handleAgreement(Feeling feeling) {
    if (feeling == Feeling.agree) {
      final jp = pickRandom(_vocab.agreePatternsJp);
      final en = pickRandom(_vocab.agreePatternsEn);

      // Add a follow-up if we have context
      if (_lastEntityId != null) {
        final entity = _vocab.entities.where((e) => e.id == _lastEntityId).firstOrNull;
        if (entity != null && _turnCount > 1) {
          final fJp = _pickPattern(_vocab.followUpPatternsJp, entity);
          final fEn = _pickPattern(_vocab.followUpPatternsEn, entity);
          return AdaptiveResponse(text: '$jp\n$fJp', english: '$en\n$fEn');
        }
      }
      return AdaptiveResponse(text: jp, english: en);
    }

    // Disagree
    return AdaptiveResponse(
      text: 'そうですか! じゃあ、何が好きですか? 😊',
      english: 'I see! Then, what do you like?',
    );
  }

  AdaptiveResponse _handleEnglishInput(String lower) {
    // Try to find entities even in English text
    final matches = <_Match>[];
    for (final e in _vocab.entities) {
      for (final trigger in e.triggers) {
        if (lower.contains(trigger.toLowerCase())) {
          matches.add(_Match(e));
          break;
        }
      }
    }

    if (matches.isNotEmpty) {
      // Found something — respond to it AND suggest Japanese
      final ent = matches.first.entity;
      _mentionedEntities.add(ent.id);
      _lastEntityId = ent.id;
      return AdaptiveResponse(
        text: '${ent.jp}ですね! 日本語では「${ent.jp}」(${ent.romaji}) と言いますよ! 😊',
        english: '${ent.en}! In Japanese we say "${ent.jp}" (${ent.romaji})!',
      );
    }

    // Can't match anything — gentle encouragement
    final suggestions = [
      AdaptiveResponse(
        text: '日本語で話してみましょう! 大丈夫、間違えてもいいですよ! 😊',
        english: 'Let\'s try in Japanese! It\'s okay to make mistakes!',
      ),
      AdaptiveResponse(
        text: '英語も分かりますよ! でも日本語も試してみてください! 💪',
        english: 'I understand English! But try Japanese too!',
      ),
      AdaptiveResponse(
        text: 'なるほど! 日本語でもう一度言えますか? お手伝いしますよ! 😊',
        english: 'I see! Can you say it in Japanese? I\'ll help!',
      ),
    ];
    return pickRandom(suggestions);
  }

  AdaptiveResponse _fallbackWithFollowUp() {
    // If we have context, ask a follow-up about previous entity
    if (_lastEntityId != null && _turnCount > 1) {
      final entity = _vocab.entities.where((e) => e.id == _lastEntityId).firstOrNull;
      if (entity != null) {
        final jp = _pickPattern(_vocab.followUpPatternsJp, entity);
        final en = _pickPattern(_vocab.followUpPatternsEn, entity);
        return AdaptiveResponse(
          text: 'そうですか! $jp',
          english: 'I see! $en',
        );
      }
    }
    return _fallback();
  }

  AdaptiveResponse _fallback() {
    final r = pickRandom(_vocab.fallbacks);
    return AdaptiveResponse(text: r.jp, english: r.en);
  }

  // ==========================================
  // PATTERN HELPERS
  // ==========================================

  String _pickPattern(List<String> patterns, VocabEntity entity) {
    if (patterns.isEmpty) return entity.jp;
    final pattern = patterns[_rng.nextInt(patterns.length)];
    return pattern
        .replaceAll('{jp}', entity.jp)
        .replaceAll('{en}', entity.en)
        .replaceAll('{romaji}', entity.romaji);
  }
}
