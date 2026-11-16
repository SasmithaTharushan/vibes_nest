import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/wellness_models.dart';

/// Reads and writes one user's wellness data in Firestore.
///
/// Everything lives under `users/{uid}/...`, so the security rules can allow
/// each person to touch only their own documents. Firestore caches data on the
/// device, so the app keeps working offline and syncs when back online.
class WellnessRepository {
  WellnessRepository(this._db, this.uid);

  final FirebaseFirestore _db;
  final String uid;

  DocumentReference<Map<String, dynamic>> get _user =>
      _db.collection('users').doc(uid);
  CollectionReference<Map<String, dynamic>> get _moods =>
      _user.collection('moods');
  CollectionReference<Map<String, dynamic>> get _sleep =>
      _user.collection('sleep');
  CollectionReference<Map<String, dynamic>> get _journal =>
      _user.collection('journal');
  CollectionReference<Map<String, dynamic>> get _tasks =>
      _user.collection('tasks');
  CollectionReference<Map<String, dynamic>> get _chat =>
      _user.collection('chat');
  CollectionReference<Map<String, dynamic>> get _hugged =>
      _user.collection('hugged');
  DocumentReference<Map<String, dynamic>> get _garden =>
      _user.collection('garden').doc('stats');

  // ---- My Garden ----
  Stream<GardenStats> watchGarden() =>
      _garden.snapshots().map((s) => GardenStats.fromMap(s.data()));

  /// Adds points for a finished self-care activity and updates the streak.
  Future<GardenStats> award(Activity activity, {DateTime? now}) =>
      _db.runTransaction((tx) async {
        final current = GardenStats.fromMap((await tx.get(_garden)).data());
        final next = current.after(activity, now ?? DateTime.now());
        tx.set(_garden, next.toMap());
        return next;
      });

  // ---- Talk to Nest ----
  Stream<List<ChatMessage>> watchChat({int limit = 100}) => _chat
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map(ChatMessage.fromDoc).toList().reversed.toList());

  Future<void> addChatMessage({
    required bool fromUser,
    required String text,
    String? tool,
    DateTime? at,
  }) =>
      _chat.add(ChatMessage(
        id: '',
        fromUser: fromUser,
        text: text,
        tool: tool,
        createdAt: at ?? DateTime.now(),
      ).toMap());

  Future<void> clearChat() => _deleteAll(_chat);

  // ---- Mood ----
  Stream<List<MoodEntry>> watchMoods({int limit = 30}) => _moods
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map(MoodEntry.fromDoc).toList().reversed.toList());

  Future<void> addMood(int mood, {DateTime? at, bool award = true}) async {
    await _moods.add(
        MoodEntry(id: '', mood: mood, createdAt: at ?? DateTime.now()).toMap());
    if (award) await this.award(Activity.mood);
  }

  // ---- Sleep ----
  Stream<List<SleepEntry>> watchSleep({int limit = 14}) => _sleep
      .orderBy('wakeTime', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map(SleepEntry.fromDoc).toList());

  Future<void> addSleep(DateTime bed, DateTime wake) async {
    await _sleep.add(SleepEntry(
            id: '', bedTime: bed, wakeTime: wake, createdAt: DateTime.now())
        .toMap());
    await award(Activity.sleep);
  }

  Future<void> deleteSleep(String id) => _sleep.doc(id).delete();

  // ---- Journal ----
  Stream<List<JournalEntry>> watchJournal() => _journal
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(JournalEntry.fromDoc).toList());

  Future<void> addJournal(String text, {DateTime? at, bool award = true}) async {
    await _journal.add(
        JournalEntry(id: '', text: text, createdAt: at ?? DateTime.now())
            .toMap());
    if (award) await this.award(Activity.journal);
  }

  Future<void> deleteJournal(String id) => _journal.doc(id).delete();

  Future<void> clearJournal() => _deleteAll(_journal);

  // ---- Tasks ----
  Stream<List<TaskItem>> watchTasks() => _tasks
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map(TaskItem.fromDoc).toList());

  Future<void> addTask(String text) => _tasks.add(TaskItem(
          id: '', text: text, done: false, createdAt: DateTime.now())
      .toMap());

  Future<void> setTaskDone(String id, bool done) =>
      _tasks.doc(id).update({'done': done});

  Future<void> deleteTask(String id) => _tasks.doc(id).delete();

  // ---- Account ----
  Future<void> saveProfile({required String name, required String email}) =>
      _user.set({
        'name': name,
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  /// Deletes every document this user owns. Used before deleting the account.
  Future<void> deleteAllData() async {
    for (final c in [_moods, _sleep, _journal, _tasks, _chat, _hugged]) {
      await _deleteAll(c);
    }
    await _garden.delete();
    // Remove my community posts too (they are anonymous, but still mine).
    final myPosts =
        await _db.collection('posts').where('authorId', isEqualTo: uid).get();
    for (final p in myPosts.docs) {
      await p.reference.delete();
    }
    await _user.delete();
  }

  Future<void> _deleteAll(CollectionReference<Map<String, dynamic>> c) async {
    final snap = await c.get();
    // Firestore batches allow up to 500 writes.
    for (var i = 0; i < snap.docs.length; i += 450) {
      final batch = _db.batch();
      for (final d in snap.docs.skip(i).take(450)) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
  }
}
