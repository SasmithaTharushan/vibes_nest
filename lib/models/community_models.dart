import 'package:cloud_firestore/cloud_firestore.dart';

/// Community topics. Kept in sync with firestore.rules.
const communityTopics = [
  'Dealing with Anxiety',
  'Self-Care Tips',
  'Mindfulness',
  'Gratitude',
];

const maxPostLength = 1000;

/// Posts hide automatically once this many people report them.
const reportsToHide = 3;

/// A friendly, anonymous nickname derived from the user's account ID.
///
/// The same person always gets the same nickname, but it never reveals their
/// real name or email.
String nicknameFor(String uid) {
  const adjectives = [
    'Calm', 'Gentle', 'Brave', 'Kind', 'Quiet', 'Bright', 'Hopeful', 'Steady',
    'Warm', 'Patient', 'Curious', 'Peaceful', 'Sunny', 'Soft', 'Bold', 'Wise',
  ];
  const animals = [
    'Otter', 'Owl', 'Panda', 'Dolphin', 'Robin', 'Elephant', 'Fox', 'Turtle',
    'Koala', 'Deer', 'Swan', 'Leopard', 'Hummingbird', 'Peacock', 'Lotus Bee',
    'Whale',
  ];
  // Stable hash (String.hashCode is not guaranteed stable across platforms).
  var h = 0;
  for (final c in uid.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return '${adjectives[h % adjectives.length]} '
      '${animals[(h ~/ adjectives.length) % animals.length]}';
}

class CommunityPost {
  final String id;
  final String authorId;
  final String nickname;
  final String topic;
  final String text;
  final DateTime createdAt;
  final int hugs;
  final int reports;
  final bool hidden;

  const CommunityPost({
    required this.id,
    required this.authorId,
    required this.nickname,
    required this.topic,
    required this.text,
    required this.createdAt,
    this.hugs = 0,
    this.reports = 0,
    this.hidden = false,
  });

  factory CommunityPost.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final created = d['createdAt'];
    return CommunityPost(
      id: doc.id,
      authorId: d['authorId'] as String? ?? '',
      nickname: d['nickname'] as String? ?? 'Someone',
      topic: d['topic'] as String? ?? '',
      text: d['text'] as String? ?? '',
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
      hugs: (d['hugs'] as num?)?.toInt() ?? 0,
      reports: (d['reports'] as num?)?.toInt() ?? 0,
      hidden: d['hidden'] as bool? ?? false,
    );
  }
}
