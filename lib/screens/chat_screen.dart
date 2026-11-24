import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ai_service.dart';
import '../core/widgets/nova_background.dart';
import '../core/widgets/nova_header_icon_button.dart';
import '../core/widgets/nova_living_core.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  bool isAnimated;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isAnimated = true,
  }) : timestamp = timestamp ?? DateTime.now();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiService _aiService = AiService();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Hi, I\'m NovaMind — your neural copilot for learning, coding, and peak focus.\n\nAsk me anything, or tap a spark prompt below to test my intelligence!',
      isUser: false,
      isAnimated: true,
    ),
  ];

  final List<String> _sparkPrompts = [
    '⚡ Explain Quantum Computing in 60s',
    '💡 7-Day Flutter Mastery Roadmap',
    '🔥 Debug my recursive code logic',
    '🎯 3 High-Yield Study Hacks',
    '🧠 How does Neural Plasticity work?',
  ];

  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? preset]) async {
    final message = (preset ?? _controller.text).trim();

    if (message.isEmpty || _loading) return;

    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true, isAnimated: true));
      _loading = true;
      if (preset == null) {
        _controller.clear();
      }
    });

    _scrollToBottom();

    try {
      final reply = await _aiService.chat(message);

      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text: reply.isEmpty ? 'I could not generate a response.' : reply,
            isUser: false,
            isAnimated: false, // will animate with typewriter
          ),
        );
        _loading = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text:
                'Focusing connection... Here is a tip: Small, consistent daily blocks generate compound mastery. What would you like to review next?',
            isUser: false,
            isAnimated: true,
          ),
        );
        _loading = false;
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 140), () {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E1035),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF7C3AED)),
        ),
        content: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF22D3EE),
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Copied to clipboard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B16),
      body: Stack(
        children: [
          const NovaBackground(),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),

                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: _messages.length + (_loading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_loading && index == _messages.length) {
                        return const _TypingBubble();
                      }

                      final message = _messages[index];

                      return _MessageBubble(
                        message: message,
                        onCopy: () => _copyToClipboard(message.text),
                      );
                    },
                  ),
                ),

                // Spark Prompts Carousel
                _buildSparkPromptsBar(),

                _buildInputBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF080B16).withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          NovaHeaderIconButton(
            icon: Navigator.canPop(context)
                ? Icons.arrow_back_ios_new_rounded
                : Icons.auto_awesome_rounded,
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),

          const SizedBox(width: 12),

          // Mini Core Orb Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                  blurRadius: 14,
                ),
              ],
            ),
            child: const NovaLivingCore(size: 40),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NovaMind AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '●',
                      style: TextStyle(color: Color(0xFF22C55E), fontSize: 10),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Gemini 3.5 Flash • Ultra-Fast',
                      style: TextStyle(
                        color: Color(0xFF22D3EE),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          NovaHeaderIconButton(
            icon: Icons.delete_outline_rounded,
            onTap: () {
              setState(() {
                _messages
                  ..clear()
                  ..add(
                    ChatMessage(
                      text: 'Memory refreshed. What are we mastering next?',
                      isUser: false,
                      isAnimated: true,
                    ),
                  );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSparkPromptsBar() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _sparkPrompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final prompt = _sparkPrompts[i];
          return GestureDetector(
            onTap: () => _sendMessage(prompt),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF13172E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                prompt,
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 88),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1424).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask NovaMind anything...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                GestureDetector(
                  onTap: () => _sendMessage(),
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF22D3EE)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22D3EE).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _loading
                          ? Icons.hourglass_top_rounded
                          : Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback onCopy;

  const _MessageBubble({required this.message, required this.onCopy});

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  String _displayedText = '';
  Timer? _typewriterTimer;

  @override
  void initState() {
    super.initState();
    if (widget.message.isUser || widget.message.isAnimated) {
      _displayedText = widget.message.text;
    } else {
      _startTypewriter();
    }
  }

  void _startTypewriter() {
    final fullText = widget.message.text;
    int charIndex = 0;
    // Fast typewriter: 4 characters per 18ms
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 18), (
      timer,
    ) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      charIndex = (charIndex + 4).clamp(0, fullText.length);
      setState(() {
        _displayedText = fullText.substring(0, charIndex);
      });
      if (charIndex >= fullText.length) {
        widget.message.isAnimated = true;
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;
    final isDone = widget.message.isAnimated || isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(isUser ? 22 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 22),
          ),
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF22D3EE)],
                )
              : LinearGradient(
                  colors: [
                    const Color(0xFF13172E).withValues(alpha: 0.95),
                    const Color(0xFF101326).withValues(alpha: 0.95),
                  ],
                ),
          border: Border.all(
            color: isUser
                ? Colors.transparent
                : const Color(0xFF8B5CF6).withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: _displayedText,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: isUser ? 1 : 0.92),
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!isDone)
                    const TextSpan(
                      text: ' ▍',
                      style: TextStyle(
                        color: Color(0xFF22D3EE),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            if (!isUser && isDone) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: widget.onCopy,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF13172E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(
                color: Color(0xFF22D3EE),
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'NovaMind is synthesizing...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
