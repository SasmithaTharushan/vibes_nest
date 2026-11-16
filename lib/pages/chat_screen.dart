import 'package:material_ui/material_ui.dart';

import 'breath_control_page.dart';
import 'crisis_help_page.dart';
import 'let_it_go_page.dart';
import 'sleep_traking_page.dart';
import 'stay_calm_page.dart';

/// A supportive companion chat.
///
/// For now it replies with caring, rule-based messages and points people to
/// the right tool in the app. Phase 3 will replace [_replyTo] with a real AI
/// model (Gemini through Firebase), keeping the crisis check in front of it.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _Message {
  final bool fromUser;
  final String text;
  final _Action? action;
  const _Message(this.fromUser, this.text, {this.action});
}

class _Action {
  final String label;
  final WidgetBuilder builder;
  const _Action(this.label, this.builder);
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<_Message> _messages = [
    const _Message(false,
        "Hi, I'm here for you. How are you feeling right now? You can tell me anything."),
  ];

  static const _crisisWords = [
    'suicide', 'suicidal', 'kill myself', 'end my life', 'end it all',
    'self harm', 'self-harm', 'hurt myself', 'cut myself', 'want to die',
    "don't want to live", 'no reason to live',
  ];

  bool _containsAny(String text, List<String> words) =>
      words.any((w) => text.contains(w));

  _Message _replyTo(String input) {
    final text = input.toLowerCase();

    if (_containsAny(text, _crisisWords)) {
      return _Message(
        false,
        "I'm really sorry you're feeling this way, and I'm glad you told me. "
        "You deserve support right now from a real person. Please call the "
        "1926 National Mental Health Helpline (free, 24/7), or tap below for "
        "more options. If you are in immediate danger, call 119.",
        action: _Action('Get help now', (_) => const CrisisHelpPage()),
      );
    }
    if (_containsAny(text, ['anxious', 'anxiety', 'panic', 'scared', 'nervous', 'overwhelm'])) {
      return _Message(
        false,
        "That sounds really hard. When anxiety rises, grounding yourself in "
        "the present can help. Want to try the 5-4-3-2-1 exercise together?",
        action: _Action('Start grounding', (_) => const StayCalmPage()),
      );
    }
    if (_containsAny(text, ['stress', 'stressed', 'tense', 'angry', 'frustrat'])) {
      return _Message(
        false,
        "Stress builds up in the body. A few minutes of slow breathing can "
        "calm your nervous system. Shall we breathe together?",
        action: _Action('Breathe with me', (_) => const BreathControlPage()),
      );
    }
    if (_containsAny(text, ['sleep', 'insomnia', 'tired', 'exhausted', "can't rest"])) {
      return _Message(
        false,
        "Rest matters so much. Tracking your sleep can help you spot patterns, "
        "and 4-7-8 breathing before bed helps many people fall asleep.",
        action: _Action('Open sleep tracker', (_) => const SleepTrackingPage()),
      );
    }
    if (_containsAny(text, ['sad', 'down', 'lonely', 'alone', 'cry', 'depress', 'hopeless', 'worried', 'worry'])) {
      return _Message(
        false,
        "I hear you, and your feelings are valid. Sometimes writing things "
        "down helps lift the weight a little. Would you like to let it out?",
        action: _Action('Write it down', (_) => const LetItGoPage()),
      );
    }
    if (_containsAny(text, ['happy', 'good', 'great', 'better', 'calm', 'fine', 'okay'])) {
      return const _Message(false,
          "I'm so glad to hear that! What's one thing that made today a little better?");
    }
    if (_containsAny(text, ['thank'])) {
      return const _Message(false,
          "You're welcome. I'm here whenever you need to talk. Take care of yourself.");
    }
    return const _Message(false,
        "Thank you for sharing that with me. Tell me more. What's on your mind, "
        "and how is it making you feel?");
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(true, text));
      _messages.add(_replyTo(text));
    });
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talk to Nest'),
        actions: [
          IconButton(
            tooltip: 'Get help now',
            icon: const Icon(Icons.sos, color: Colors.red),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CrisisHelpPage())),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _buildBubble(_messages[i]),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Type how you feel...',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(_Message m) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: m.fromUser ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(m.text,
                style: TextStyle(
                    color: m.fromUser ? scheme.onPrimary : scheme.onSurface,
                    height: 1.35)),
            if (m.action != null) ...[
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: m.action!.builder)),
                child: Text(m.action!.label),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
