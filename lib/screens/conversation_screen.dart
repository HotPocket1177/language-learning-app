import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/conversation_data.dart';
import '../providers/study_provider.dart';
import '../services/claude_api_service.dart';
import '../services/conversation_service.dart';
import '../utils/romaji_converter.dart';
import '../widgets/message_bubble.dart';

class ConversationScreen extends StatefulWidget {
  final ConversationTopic topic;

  const ConversationScreen({super.key, required this.topic});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ConversationService _service = ConversationService();
  late final ClaudeApiService _ai;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  bool _isTyping = false;
  bool _prefsLoaded = false;
  int _exchangeCount = 0;

  // AI-powered suggestions (update after each Kuma response)
  List<AiSuggestion> _suggestions = [];

  static const int _typedXp = 30;

  @override
  void initState() {
    super.initState();
    _ai = ClaudeApiService(
      topicId: widget.topic.id,
      topicName: widget.topic.name,
    );
    _init();
  }

  Future<void> _init() async {
    await _service.loadPreferences();
    _service.startAdaptiveConversation(widget.topic);

    // Show the screen immediately with typing indicator
    if (mounted) {
      setState(() {
        _prefsLoaded = true;
        _isTyping = true;
      });
    }

    // Get Kuma's AI opening message
    final opening = await _ai.getOpeningMessage();

    _service.addKumaTypedMessage(
      text: opening.message,
      romaji: '',
      english: opening.english,
    );

    if (mounted) {
      setState(() {
        _isTyping = false;
        _suggestions = opening.suggestions;
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // =============================================
  // SEND — AI-powered response
  // =============================================

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isTyping || _service.isEnded) return;

    HapticFeedback.lightImpact();

    // Convert romaji → hiragana on send (not while typing)
    String displayText = text;
    if (RomajiConverter.isRomaji(text) &&
        !RomajiConverter.containsJapanese(text)) {
      displayText = RomajiConverter.toHiragana(text);
    }

    // Add user message to chat immediately
    _service.addTypedMessage(
      text: displayText,
      romaji: RomajiConverter.isRomaji(text) ? text : '',
      english: '',
    );

    _textController.clear();
    _exchangeCount++;
    setState(() {
      _isTyping = true;
      _suggestions = []; // clear while loading new ones
    });
    _scrollToBottom();

    // Get AI response (typing indicator shows during real API latency)
    final response = await _ai.sendMessage(text);

    if (!mounted) return;

    _service.addKumaTypedMessage(
      text: response.message,
      romaji: '',
      english: response.english,
    );

    setState(() {
      _isTyping = false;
      _suggestions = response.suggestions;
    });
    _scrollToBottom();

    // Check if conversation should end
    if (response.isEnd) {
      _service.markEnded();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _showCompletionDialog();
      });
    }
  }

  // =============================================
  // HINTS — opens bottom sheet
  // =============================================

  void _showHintSheet() {
    // Use AI suggestions if available, otherwise static hints
    final hints =
        _suggestions.isNotEmpty ? _suggestions : _ai.getStaticHints();
    if (hints.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Image.asset('assets/images/kuma.png', width: 28, height: 28),
                const SizedBox(width: 8),
                const Text(
                  'Try saying:',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8b6f47),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...hints.map((hint) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      _textController.text = hint.japanese;
                      _textController.selection = TextSelection.fromPosition(
                        TextPosition(offset: hint.japanese.length),
                      );
                      Navigator.pop(ctx);
                      _inputFocus.requestFocus();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EBE0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF8b6f47)
                              .withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hint.japanese,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3a2a1a),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${hint.romaji}  •  ${hint.english}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // =============================================
  // COMPLETION
  // =============================================

  Future<void> _showCompletionDialog() async {
    final provider = Provider.of<StudyProvider>(context, listen: false);
    provider.addConversationXp(_typedXp);
    await _service.saveToHistory();

    if (!mounted) return;

    final accuracy = (_ai.accuracyScore * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Image.asset('assets/images/kuma.png', width: 36, height: 36),
            const SizedBox(width: 8),
            const Expanded(child: Text('Great conversation!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatRow(
                icon: Icons.chat,
                label: 'Messages typed',
                value: '$_exchangeCount'),
            const SizedBox(height: 8),
            _StatRow(
                icon: Icons.translate,
                label: 'Japanese chars',
                value: '${_ai.japaneseCharsTyped}'),
            const SizedBox(height: 8),
            _StatRow(
                icon: Icons.check_circle_outline,
                label: 'Accuracy',
                value: '$accuracy%'),
            const SizedBox(height: 8),
            _StatRow(
                icon: Icons.star,
                label: 'XP earned',
                value: '+$_typedXp'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5EBE0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Image.asset('assets/images/kuma.png',
                      width: 28, height: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      accuracy >= 80
                          ? 'Your typing is amazing! 上手! ✨'
                          : accuracy >= 50
                              ? "Nice effort! You're improving! 頑張って!"
                              : "Keep practicing! You'll get better! 大丈夫!",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8b6f47),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              _ai.reset();
              _service.reset();
              _service.startAdaptiveConversation(widget.topic);

              setState(() {
                _exchangeCount = 0;
                _isTyping = true;
                _suggestions = [];
              });

              final opening = await _ai.getOpeningMessage();
              if (!mounted) return;

              _service.addKumaTypedMessage(
                text: opening.message,
                romaji: '',
                english: opening.english,
              );
              setState(() {
                _isTyping = false;
                _suggestions = opening.suggestions;
              });
              _scrollToBottom();
            },
            child: const Text('Chat Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('New Topic'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8b6f47),
              foregroundColor: Colors.white,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  // =============================================
  // BUILD
  // =============================================

  @override
  Widget build(BuildContext context) {
    if (!_prefsLoaded && !_isTyping) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final allMessages = _service.messages;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/kuma.png',
                  width: 36, height: 36),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kuma-san',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.topic.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // AI indicator badge — green if live AI, orange if fallback
          if (_ai.isUsingAi)
            GestureDetector(
              onTap: () {
                final status = _ai.lastWasAiResponse
                    ? 'Connected to Claude AI'
                    : 'Offline mode (fallback)${_ai.lastError != null ? '\nError: ${_ai.lastError}' : ''}';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(status),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _ai.lastWasAiResponse
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.orange.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _ai.lastWasAiResponse
                          ? Icons.auto_awesome
                          : Icons.cloud_off,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _ai.lastWasAiResponse ? 'AI' : 'Offline',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          IconButton(
            icon: Text(
              _service.showRomaji ? 'a' : 'あ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _service.showRomaji
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
            tooltip: 'Toggle romaji',
            onPressed: () {
              setState(() {
                _service.setShowRomaji(!_service.showRomaji);
              });
            },
          ),
          IconButton(
            icon: Text(
              'EN',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _service.showTranslation
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
            tooltip: 'Toggle translation',
            onPressed: () {
              setState(() {
                _service.setShowTranslation(!_service.showTranslation);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: GestureDetector(
              onTap: () => _inputFocus.unfocus(),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                itemCount: allMessages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == allMessages.length) {
                    return const TypingIndicator();
                  }
                  final msg = allMessages[index];
                  return MessageBubble(
                    text: msg.text,
                    romaji: msg.romaji,
                    english: msg.english,
                    isKuma: msg.speaker == 'kuma',
                    showRomaji: _service.showRomaji,
                    showTranslation: _service.showTranslation,
                  );
                },
              ),
            ),
          ),

          // AI-powered suggestion chips
          if (_suggestions.isNotEmpty && !_service.isEnded)
            Container(
              height: 44,
              margin: const EdgeInsets.only(bottom: 4),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _suggestions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final s = _suggestions[index];
                  return ActionChip(
                    label: Text(
                      s.japanese,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF3a2a1a)),
                    ),
                    tooltip: '${s.romaji} — ${s.english}',
                    backgroundColor: const Color(0xFFF5EBE0),
                    side: BorderSide(
                      color: const Color(0xFF8b6f47).withValues(alpha: 0.3),
                    ),
                    onPressed: () {
                      _textController.text = s.japanese;
                      _textController.selection = TextSelection.fromPosition(
                        TextPosition(offset: s.japanese.length),
                      );
                      _inputFocus.requestFocus();
                    },
                  );
                },
              ),
            ),

          // Input area — completely free, no interruptions
          if (!_service.isEnded)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5EBE0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 6, 8, 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Text('💡',
                            style: TextStyle(fontSize: 20)),
                        tooltip: 'Hint',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 36, minHeight: 36),
                        onPressed: _showHintSheet,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          focusNode: _inputFocus,
                          maxLength: 200,
                          maxLines: 3,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: const Color(0xFF8b6f47)
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF8b6f47),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.send_rounded),
                        color: const Color(0xFF8b6f47),
                        onPressed: () => _sendMessage(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // End state
          if (_service.isEnded && !_isTyping)
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF5EBE0),
              child: SafeArea(
                top: false,
                child: Text(
                  'Conversation complete!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF8b6f47)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8b6f47),
          ),
        ),
      ],
    );
  }
}
