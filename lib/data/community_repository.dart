import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/community_models.dart';

/// Shared community posts.
///
/// Layout (all enforced by firestore.rules):
/// - `posts/{postId}`: the post, with public counters `hugs` and `reports`.
/// - `posts/{postId}/reports/{uid}`: one report per person, private.
/// - `users/{uid}/hugged/{postId}`: private marker of posts I hugged, which
///   also stops the same person hugging twice.
class CommunityRepository {
  CommunityRepository(this._db, this.uid);

  final FirebaseFirestore _db;
  final String uid;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection('posts');
  CollectionReference<Map<String, dynamic>> get _myHugs =>
      _db.collection('users').doc(uid).collection('hugged');

  String get myNickname => nicknameFor(uid);

  /// Visible posts, newest first.
  Stream<List<CommunityPost>> watchPosts({int limit = 100}) => _posts
      .where('hidden', isEqualTo: false)
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map(CommunityPost.fromDoc).toList());

  /// IDs of posts I have hugged.
  Stream<Set<String>> watchMyHugs() =>
      _myHugs.snapshots().map((s) => s.docs.map((d) => d.id).toSet());

  Future<void> publish({required String topic, required String text}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length > maxPostLength) {
      throw ArgumentError('Post must be 1–$maxPostLength characters.');
    }
    if (!communityTopics.contains(topic)) {
      throw ArgumentError('Unknown topic: $topic');
    }
    return _posts.add({
      'authorId': uid,
      'nickname': myNickname,
      'topic': topic,
      'text': trimmed,
      'createdAt': Timestamp.now(),
      'hugs': 0,
      'reports': 0,
      'hidden': false,
    });
  }

  /// Sends a hug, or takes it back if already sent.
  Future<void> toggleHug(CommunityPost post, {required bool hugged}) {
    final batch = _db.batch();
    final marker = _myHugs.doc(post.id);
    if (hugged) {
      batch.delete(marker);
      batch.update(_posts.doc(post.id), {'hugs': FieldValue.increment(-1)});
    } else {
      batch.set(marker, {'createdAt': Timestamp.now()});
      batch.update(_posts.doc(post.id), {'hugs': FieldValue.increment(1)});
    }
    return batch.commit();
  }

  /// Reports a post. Returns false if I already reported it.
  Future<bool> report(CommunityPost post) {
    final postRef = _posts.doc(post.id);
    final myReport = postRef.collection('reports').doc(uid);
    // A transaction reads the latest count, so simultaneous reports from
    // different people can't overwrite each other.
    return _db.runTransaction((tx) async {
      if ((await tx.get(myReport)).exists) return false;
      final latest = await tx.get(postRef);
      final newCount = ((latest.data()?['reports'] as num?)?.toInt() ?? 0) + 1;
      tx.set(myReport, {'createdAt': Timestamp.now()});
      tx.update(postRef, {
        'reports': newCount,
        'hidden': newCount >= reportsToHide,
      });
      return true;
    });
  }

  Future<void> delete(CommunityPost post) => _posts.doc(post.id).delete();
}
