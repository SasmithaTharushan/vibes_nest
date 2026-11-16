import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/community_repository.dart';
import '../models/community_models.dart';
import '../services/app_services.dart';
import '../services/crisis_detector.dart';
import 'crisis_help_page.dart';

/// Community: an anonymous, shared "share your thoughts" wall.
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  static const _whatsAppUrl =
      'https://chat.whatsapp.com/Jn6xBKok9AoJX9glvpnsay';

  String? _topicFilter;

  CommunityRepository get _repo => AppServices.community(context);

  void _toast(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _openWhatsApp() async {
    final ok = await launchUrl(Uri.parse(_whatsAppUrl),
        mode: LaunchMode.externalApplication);
    if (!ok && mounted) _toast('Could not open WhatsApp.');
  }

  /// If the post sounds like a crisis, offer help before publishing.
  /// Returns true to continue publishing.
  Future<bool> _crisisCheck(String text) async {
    if (!CrisisDetector.isCrisis(text)) return true;
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.favorite, color: Colors.red),
        title: const Text('You don\'t have to carry this alone'),
        content: const Text(
            'It sounds like you\'re going through something really painful. '
            'A trained listener can help right now: call 1926 or 1333, free '
            'and 24/7.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, 'post'),
              child: const Text('Post anyway')),
          FilledButton(
              onPressed: () => Navigator.pop(context, 'help'),
              child: const Text('Get help now')),
        ],
      ),
    );
    if (choice == 'help' && mounted) {
      await Navigator.push(context,
          MaterialPageRoute(builder: (_) => const CrisisHelpPage()));
      return false;
    }
    return choice == 'post';
  }

  Future<void> _compose() async {
    final repo = _repo;
    final result = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ComposeSheet(
        nickname: repo.myNickname,
        initialTopic: _topicFilter ?? communityTopics.first,
      ),
    );
    if (result == null || !mounted) return;
    if (!await _crisisCheck(result.$2)) return;
    try {
      await repo.publish(topic: result.$1, text: result.$2);
    } catch (_) {
      if (mounted) _toast('Could not publish. Check your connection.');
    }
  }

  Future<void> _report(CommunityPost post) async {
    final repo = _repo;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report this post?'),
        content: const Text(
            'Report posts that are unkind, unsafe, spam, or share someone\'s '
            'private information. Posts are hidden after several reports.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Report')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final reported = await repo.report(post);
      if (mounted) {
        _toast(reported
            ? 'Thanks. We\'ve recorded your report.'
            : 'You\'ve already reported this post.');
      }
    } catch (_) {
      if (mounted) _toast('Could not send report. Try again.');
    }
  }

  Future<void> _delete(CommunityPost post) async {
    final repo = _repo;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete your post?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) await repo.delete(post);
  }

  @override
  Widget build(BuildContext context) {
    final repo = _repo;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<Set<String>>(
        stream: repo.watchMyHugs(),
        builder: (context, hugSnap) {
          final myHugs = hugSnap.data ?? const <String>{};
          return StreamBuilder<List<CommunityPost>>(
            stream: repo.watchPosts(),
            builder: (context, snapshot) {
              final all = snapshot.data ?? const <CommunityPost>[];
              final visible = _topicFilter == null
                  ? all
                  : all.where((p) => p.topic == _topicFilter).toList();
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: Colors.teal.shade50,
                    child: ListTile(
                      leading:
                          Image.asset('assets/images/whatsapp.png', height: 40),
                      title: const Text('Join our WhatsApp community',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle:
                          const Text('Chat with others on the same journey'),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: _openWhatsApp,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This is a kind, anonymous space. You appear as '
                    '"${repo.myNickname}".',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _topicFilter == null,
                        onSelected: (_) => setState(() => _topicFilter = null),
                      ),
                      for (final t in communityTopics)
                        ChoiceChip(
                          label: Text(t),
                          selected: _topicFilter == t,
                          onSelected: (_) => setState(() => _topicFilter = t),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (snapshot.hasError)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text('Could not load posts. Check your connection.',
                          textAlign: TextAlign.center),
                    )
                  else if (!snapshot.hasData)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (visible.isEmpty)
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
                    for (final post in visible)
                      _PostCard(
                        post: post,
                        isMine: post.authorId == repo.uid,
                        hugged: myHugs.contains(post.id),
                        onHug: () => repo.toggleHug(post,
                            hugged: myHugs.contains(post.id)),
                        onReport: () => _report(post),
                        onDelete: () => _delete(post),
                      ),
                  const SizedBox(height: 80),
                ],
              );
            },
          );
        },
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
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.isMine,
    required this.hugged,
    required this.onHug,
    required this.onReport,
    required this.onDelete,
  });

  final CommunityPost post;
  final bool isMine;
  final bool hugged;
  final VoidCallback onHug;
  final VoidCallback onReport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
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
                  child: Text(post.nickname[0],
                      style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isMine ? '${post.nickname} (you)' : post.nickname,
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
                  tooltip: 'More',
                  onSelected: (v) => v == 'delete' ? onDelete() : onReport(),
                  itemBuilder: (_) => [
                    if (isMine)
                      const PopupMenuItem(value: 'delete', child: Text('Delete'))
                    else
                      const PopupMenuItem(value: 'report', child: Text('Report')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(post.text, style: const TextStyle(height: 1.4)),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: isMine ? null : onHug,
                icon: Icon(hugged ? Icons.favorite : Icons.favorite_border,
                    color: Colors.pinkAccent),
                label: Text('${post.hugs} ${post.hugs == 1 ? 'hug' : 'hugs'}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The "Share your thoughts" sheet. It owns its text controller so the
/// controller lives until the sheet has fully closed.
class _ComposeSheet extends StatefulWidget {
  const _ComposeSheet({required this.nickname, required this.initialTopic});

  final String nickname;
  final String initialTopic;

  @override
  State<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends State<_ComposeSheet> {
  final _text = TextEditingController();
  late String _topic = widget.initialTopic;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Share your thoughts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('You\'ll appear as "${widget.nickname}". Your name and email '
              'are never shown.',
              style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _topic,
            decoration: const InputDecoration(labelText: 'Topic'),
            items: [
              for (final t in communityTopics)
                DropdownMenuItem(value: t, child: Text(t)),
            ],
            onChanged: (v) => setState(() => _topic = v ?? _topic),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _text,
            autofocus: true,
            maxLines: 5,
            maxLength: maxPostLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Be kind. Share something that might help others too.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              final text = _text.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(context, (_topic, text));
            },
            child: const Text('Publish post'),
          ),
        ],
      ),
    );
  }
}
