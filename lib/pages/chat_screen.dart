import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../models/wellness_models.dart';
import '../services/app_services.dart';
import '../services/companion_ai.dart';
import '../services/crisis_detector.dart';
import 'breath_control_page.dart';
import 'crisis_help_page.dart';
import 'let_it_go_page.dart';
import 'sleep_traking_page.dart';
import 'stay_calm_page.dart';

/// "Talk to Nest": a supportive AI companion.
///
/// Every message is checked on the device for crisis language first. Crisis
/// messages get a fixed reply with helplines and are never sent to the AI.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _greeting =
      "Hi, I'm Nest. I'm here to listen. How are you feeling right now?";
  static const _replyTimeout = Duration(seconds: 30);

  final _controller = TextEditingController();
  final _scroll = ScrollController();

  List<ChatMessage> _messages = const [];
  bool _sending = false;
  String? _streamingText;
  bool _offline = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Widget _pageFor(CompanionTool tool) {
    switch (tool) {
      case CompanionTool.crisis:
        return const CrisisHelpPage();
      case CompanionTool.grounding:
        return const StayCalmPage();
      case CompanionTool.breathing:
        return const BreathControlPage();
      case CompanionTool.sleep:
        return const SleepTrackingPage();
      case CompanionTool.journal:
        return const LetItGoPage();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    final repo = AppServices.repo(context);
    final ai = AppServices.companion(context);
    final history = [
      for (final m in _messages) ChatTurn(fromUser: m.fromUser, text: m.text),
    ];

    _controller.clear();
    setState(() {
      _sending = true;
      _streamingText = '';
    });
    _scrollToBottom();

    await repo.addChatMessage(fromUser: true, text: text);

    final tool = CrisisDetector.suggestTool(text);
    String reply;
    var offline = false;

    if (CrisisDetector.isCrisis(text)) {
      // Never send crisis messages to the AI: show helplines immediately.
      reply = CrisisDetector.crisisReply;
    } else {
      try {
        final buffer = StringBuffer();
        // The whole reply must arrive within the time limit, so a stuck
        // network call can never freeze the chat.
        await ai.reply(history: history, message: text).forEach((piece) {
          buffer.write(piece);
          if (!mounted) return;
          setState(() => _streamingText = buffer.toString());
          _scrollToBottom();
        }).timeout(_replyTimeout);
        if (!mounted) return;
        reply = buffer.toString().trim();
        if (reply.isEmpty) throw StateError('Empty reply');
      } catch (_) {
        // No internet, AI quota reached, or the reply was blocked.
        reply = OfflineCompanion.replyFor(text);
        offline = true;
      }
    }

    await repo.addChatMessage(fromUser: false, text: reply, tool: tool?.name);
    if (!mounted) return;
    setState(() {
      _sending = false;
      _streamingText = null;
      _offline = offline;
    });
    _scrollToBottom();
  }

  Future<void> _clearChat() async {
    final repo = AppServices.repo(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear this conversation?'),
        content: const Text('All messages with Nest will be deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (ok == true) await repo.clearChat();
  }

  @override
  Widget build(BuildContext context) {
    final repo = AppServices.repo(context);
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
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'clear') _clearChat();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'clear', child: Text('Clear chat')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const _AiNotice(),
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: repo.watchChat(),
              builder: (context, snapshot) {
                _messages = snapshot.data ?? _messages;
                final items = <Widget>[
                  _Bubble(fromUser: false, text: _greeting),
                  for (final m in _messages)
                    _Bubble(
                      fromUser: m.fromUser,
                      text: m.text,
                      tool: CompanionTool.fromName(m.tool),
                      onTool: (t) => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => _pageFor(t))),
                    ),
                  if (_sending)
                    (_streamingText ?? '').isEmpty
                        ? const _TypingBubble()
                        : _Bubble(fromUser: false, text: _streamingText!),
                ];
                return ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  children: items,
                );
              },
            ),
          ),
          if (_offline)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Nest is in offline mode. Replies are simpler until you reconnect.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 2000,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Type how you feel...',
                        counterText: '',
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
                    tooltip: 'Send',
                    onPressed: _sending ? null : _send,
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
}

class _AiNotice extends StatelessWidget {
  const _AiNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'Nest is an AI companion, not a therapist. In an emergency, tap SOS.',
        style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSecondaryContainer),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.fromUser,
    required this.text,
    this.tool,
    this.onTool,
  });

  final bool fromUser;
  final String text;
  final CompanionTool? tool;
  final ValueChanged<CompanionTool>? onTool;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: fromUser ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(text,
                style: TextStyle(
                    color: fromUser ? scheme.onPrimary : scheme.onSurface,
                    height: 1.35)),
            if (tool != null && onTool != null) ...[
              const SizedBox(height: 8),
              FilledButton.tonal(
                style: tool == CompanionTool.crisis
                    ? FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                        foregroundColor: Colors.red.shade900)
                    : null,
                onPressed: () => onTool!(tool!),
                child: Text(tool!.label),
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
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(
          width: 32,
          height: 12,
          child: LinearProgressIndicator(),
        ),
      ),
    );
  }
}
