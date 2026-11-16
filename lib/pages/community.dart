import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/app_services.dart';

/// Community page: a link to the group chat plus a "share your thoughts" wall.
///
/// Posts are saved on the device for now. Phase 4 moves them to Firestore so
/// everyone can see and reply to each other's posts.
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _Post {
  final String author;
  final String topic;
  final String text;
  final DateTime createdAt;
  int hugs;

  _Post({
    required this.author,
    required this.topic,
    required this.text,
    required this.createdAt,
    this.hugs = 0,
  });

  Map<String, dynamic> toJson() => {
        'author': author,
        'topic': topic,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'hugs': hugs,
      };

  factory _Post.fromJson(Map<String, dynamic> j) => _Post(
        author: j['author'] as String,
        topic: j['topic'] as String,
        text: j['text'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        hugs: (j['hugs'] as num?)?.toInt() ?? 0,
      );
}

class _CommunityPageState extends State<CommunityPage> {
  static const _storageKey = 'community_posts';
  static const _topics = [
    'Dealing with Anxiety',
    'Self-Care Tips',
    'Mindfulness',
    'Gratitude',
  ];
  static const _whatsAppUrl =
      'https://chat.whatsapp.com/Jn6xBKok9AoJX9glvpnsay';

  List<_Post> _posts = [];
  String? _topicFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;
    final list = (jsonDecode(raw) as List)
        .map((e) => _Post.fromJson(e as Map<String, dynamic>))
        .toList();
    if (mounted) setState(() => _posts = list);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _storageKey, jsonEncode(_posts.map((p) => p.toJson()).toList()));
  }

  Future<void> _openWhatsApp() async {
    final ok = await launchUrl(Uri.parse(_whatsAppUrl),
        mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp.')));
    }
  }

  Future<void> _compose() async {
    final textController = TextEditingController();
    String topic = _topicFilter ?? _topics.first;
    final result = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Share your thoughts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: topic,
                decoration: const InputDecoration(labelText: 'Topic'),
                items: [
                  for (final t in _topics)
                    DropdownMenuItem(value: t, child: Text(t)),
                ],
                onChanged: (v) => setSheetState(() => topic = v ?? topic),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                autofocus: true,
                maxLines: 5,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'Be kind. Share something that might help others too.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  final text = textController.text.trim();
                  if (text.isEmpty) return;
                  Navigator.pop(context, (topic, text));
                },
                child: const Text('Publish post'),
              ),
            ],
          ),
        ),
      ),
    );
    textController.dispose();
    if (result == null || !mounted) return;

    final author = AppServices.auth(context).displayName;
    setState(() {
      _posts.insert(
        0,
        _Post(
          author: author,
          topic: result.$1,
          text: result.$2,
          createdAt: DateTime.now(),
        ),
      );
    });
    await _save();
  }

  Future<void> _hug(_Post post) async {
    setState(() => post.hugs++);
    await _save();
  }

  Future<void> _delete(_Post post) async {
    setState(() => _posts.remove(post));
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _topicFilter == null
        ? _posts
        : _posts.where((p) => p.topic == _topicFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.teal.shade50,
            child: ListTile(
              leading: Image.asset('assets/images/whatsapp.png', height: 40),
              title: const Text('Join our WhatsApp community',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Chat with others on the same journey'),
              trailing: const Icon(Icons.open_in_new),
              onTap: _openWhatsApp,
            ),
          ),
          const SizedBox(height: 20),
          const Text('Topics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _topicFilter == null,
                onSelected: (_) => setState(() => _topicFilter = null),
              ),
              for (final t in _topics)
                ChoiceChip(
                  label: Text(t),
                  selected: _topicFilter == t,
                  onSelected: (_) => setState(() => _topicFilter = t),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.forum_outlined,
                      size: 64, color: Colors.teal.shade200),
                  const SizedBox(height: 12),
                  const Text('No posts yet. Be the first to share!',
                      textAlign: TextAlign.center),
                ],
              ),
            )
          else
            for (final post in visible) _buildPost(post),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _compose,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_comment),
        label: const Text('Post'),
      ),
    );
  }

  Widget _buildPost(_Post post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(
                    post.author.isNotEmpty ? post.author[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.author,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        '${post.topic} · ${DateFormat('d MMM, h:mm a').format(post.createdAt)}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'delete') _delete(post);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(post.text, style: const TextStyle(height: 1.4)),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _hug(post),
                icon: const Icon(Icons.favorite, color: Colors.pinkAccent),
                label: Text('${post.hugs} hugs'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
