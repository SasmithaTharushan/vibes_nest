import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vibes_nest/data/wellness_repository.dart';
import 'package:vibes_nest/models/wellness_models.dart';
import 'package:vibes_nest/pages/sleep_traking_page.dart';
import 'package:vibes_nest/services/auth_service.dart';
import 'package:vibes_nest/services/local_migration.dart';

void main() {
  group('resolveNight', () {
    final now = DateTime(2026, 11, 16, 9);

    test('bed before midnight, wake after midnight', () {
      final n = resolveNight(
          bedHour: 23, bedMinute: 0, wakeHour: 7, wakeMinute: 0, now: now);
      expect(n.wake.difference(n.bed), const Duration(hours: 8));
      expect(n.bed.day, 15);
      expect(n.wake.day, 16);
    });

    test('bed after midnight', () {
      final n = resolveNight(
          bedHour: 1, bedMinute: 30, wakeHour: 7, wakeMinute: 0, now: now);
      expect(n.wake.difference(n.bed), const Duration(hours: 5, minutes: 30));
    });

    test('daytime nap the same day', () {
      final n = resolveNight(
          bedHour: 14, bedMinute: 0, wakeHour: 15, wakeMinute: 0, now: now);
      expect(n.wake.difference(n.bed), const Duration(hours: 1));
    });
  });

  group('SleepEntry quality and advice', () {
    SleepEntry night(double hours) {
      final wake = DateTime(2026, 11, 16, 7);
      return SleepEntry(
        id: 'x',
        bedTime: wake.subtract(Duration(minutes: (hours * 60).round())),
        wakeTime: wake,
        createdAt: wake,
      );
    }

    test('stars follow hours slept', () {
      expect(night(3).quality, 1);
      expect(night(5).quality, 2);
      expect(night(6.5).quality, 3);
      expect(night(8).quality, 5);
      expect(night(10).quality, 4);
    });

    test('advice changes with hours', () {
      expect(sleepAdvice(3).message, contains('Very little'));
      expect(sleepAdvice(8).message, contains('Great sleep'));
    });
  });

  group('WellnessRepository', () {
    late FakeFirebaseFirestore db;
    late WellnessRepository repo;

    setUp(() {
      db = FakeFirebaseFirestore();
      repo = WellnessRepository(db, 'user-1');
    });

    test('stores moods under the user and returns them oldest first', () async {
      await repo.addMood(0, at: DateTime(2026, 11, 14));
      await repo.addMood(2, at: DateTime(2026, 11, 15));
      final moods = await repo.watchMoods().first;
      expect(moods.map((m) => m.mood), [0, 2]);

      final raw = await db.collection('users/user-1/moods').get();
      expect(raw.docs, hasLength(2));
    });

    test('journal add, delete and clear', () async {
      await repo.addJournal('first', at: DateTime(2026, 11, 14));
      await repo.addJournal('second', at: DateTime(2026, 11, 15));
      var notes = await repo.watchJournal().first;
      expect(notes.map((n) => n.text), ['second', 'first']); // newest first

      await repo.deleteJournal(notes.first.id);
      notes = await repo.watchJournal().first;
      expect(notes.map((n) => n.text), ['first']);

      await repo.clearJournal();
      expect(await repo.watchJournal().first, isEmpty);
    });

    test('sleep nights are saved with hours', () async {
      final n = resolveNight(bedHour: 23, bedMinute: 0, wakeHour: 7, wakeMinute: 0);
      await repo.addSleep(n.bed, n.wake);
      final nights = await repo.watchSleep().first;
      expect(nights.single.hours, 8);
    });

    test('tasks can be ticked off and deleted', () async {
      await repo.addTask('Call mum');
      var tasks = await repo.watchTasks().first;
      expect(tasks.single.done, isFalse);

      await repo.setTaskDone(tasks.single.id, true);
      tasks = await repo.watchTasks().first;
      expect(tasks.single.done, isTrue);

      await repo.deleteTask(tasks.single.id);
      expect(await repo.watchTasks().first, isEmpty);
    });

    test('one user cannot see another user\'s data', () async {
      await repo.addJournal('private');
      final other = WellnessRepository(db, 'user-2');
      expect(await other.watchJournal().first, isEmpty);
    });

    test('deleteAllData removes everything for the user', () async {
      await repo.saveProfile(name: 'S', email: 's@example.com');
      await repo.addMood(1);
      await repo.addJournal('note');
      await repo.addTask('task');
      await repo.deleteAllData();

      for (final c in ['moods', 'journal', 'tasks', 'sleep']) {
        final snap = await db.collection('users/user-1/$c').get();
        expect(snap.docs, isEmpty, reason: c);
      }
      expect((await db.doc('users/user-1').get()).exists, isFalse);
    });
  });

  group('LocalMigration', () {
    test('moves old on-device journal and moods to the cloud once', () async {
      SharedPreferences.setMockInitialValues({
        'journal_entries': ['newest note', 'older note'],
        'mood_data': ['0', '1', '2'],
        'profile_name': 'Old',
      });
      final repo = WellnessRepository(FakeFirebaseFirestore(), 'u');

      expect(await LocalMigration.run(repo), 5);
      expect((await repo.watchJournal().first).map((n) => n.text),
          ['newest note', 'older note']);
      expect((await repo.watchMoods().first).map((m) => m.mood), [0, 1, 2]);

      // Running again moves nothing: local copies were cleared.
      expect(await LocalMigration.run(repo), 0);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isEmpty);
    });
  });

  group('AuthService', () {
    test('sign up sets the display name and saves a profile', () async {
      final db = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth();
      final service = AuthService(auth, db);

      await service.signUp(
          name: ' Sasmitha ', email: 'sas@example.com', password: 'password123');

      expect(auth.currentUser, isNotNull);
      expect(service.displayName, 'Sasmitha');
      final profile = await db.doc('users/${auth.currentUser!.uid}').get();
      expect(profile.data()!['name'], 'Sasmitha');
    });

    test('display name falls back to the email name', () async {
      final auth = MockFirebaseAuth(
          signedIn: true, mockUser: MockUser(uid: 'u', email: 'kasun@example.com'));
      expect(AuthService(auth, FakeFirebaseFirestore()).displayName, 'kasun');
    });

    test('Firebase error codes become friendly messages', () {
      expect(AuthService.messageFor('wrong-password'),
          'Email or password is incorrect.');
      expect(AuthService.messageFor('invalid-credential'),
          'Email or password is incorrect.');
      expect(AuthService.messageFor('email-already-in-use'),
          contains('already exists'));
      expect(AuthService.messageFor('network-request-failed'),
          contains('internet'));
    });
  });
}
