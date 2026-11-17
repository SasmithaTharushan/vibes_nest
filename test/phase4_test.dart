import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:vibes_nest/data/community_repository.dart';
import 'package:vibes_nest/data/help_directory.dart';
import 'package:vibes_nest/data/wellness_repository.dart';
import 'package:vibes_nest/models/community_models.dart';
import 'package:vibes_nest/models/wellness_models.dart';
import 'package:vibes_nest/pages/community.dart';
import 'package:vibes_nest/pages/find_help_page.dart';
import 'package:vibes_nest/pages/garden_page.dart';
import 'package:vibes_nest/services/app_services.dart';
import 'package:vibes_nest/services/auth_service.dart';
import 'package:vibes_nest/services/companion_ai.dart';
import 'package:vibes_nest/widgets/text_prompt_dialog.dart';

Widget _signedIn(FakeFirebaseFirestore db, Widget page, {String uid = 'u1'}) =>
    AppServices(
      authService: AuthService(
        MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: uid, email: '$uid@x.com')),
        db,
      ),
      companionAi: const OfflineCompanion(),
      child: MaterialApp(home: page),
    );

void main() {
  group('Help directory', () {
    test('every service has a verified source and a way to reach it', () {
      for (final s in helpServices) {
        expect(s.source, isNotEmpty, reason: s.name);
        expect(s.phone != null || s.website != null, isTrue, reason: s.name);
        if (s.phone != null) {
          expect(RegExp(r'^\d+$').hasMatch(s.phone!), isTrue, reason: s.name);
        }
        if (s.whatsapp != null) {
          expect(s.whatsapp, startsWith('94'), reason: s.name);
        }
      }
    });

    test('crisis screen lists the 24/7 lines and the current Sumithrayo number',
        () {
      final numbers = crisisLines.map((s) => s.phone).toList();
      expect(numbers, containsAll(['1926', '1333', '1375', '0707308308', '119']));
      // Old number from 2017 articles; Sumithrayo's site no longer lists it.
      expect(helpServices.map((s) => s.phone), isNot(contains('0112696666')));
    });

    testWidgets('Find help page searches and filters by category',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FindHelpPage()));

      await tester.enterText(find.byType(TextField), 'befriending');
      await tester.pumpAndSettle();
      expect(find.text('Sri Lanka Sumithrayo'), findsOneWidget);
      expect(find.text('CCCline'), findsNothing);

      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text(HelpCategory.specialised.title));
      await tester.pumpAndSettle();
      expect(find.text('Sri Lanka Sumithrayo'), findsNothing);
      await tester.scrollUntilVisible(find.text('Child Helpline 1929'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('Child Helpline 1929'), findsOneWidget);
    });
  });

  group('Nicknames', () {
    test('are stable per user and never contain the uid', () {
      expect(nicknameFor('abc123'), nicknameFor('abc123'));
      expect(nicknameFor('abc123'), isNot(contains('abc123')));
      final many = {for (var i = 0; i < 50; i++) nicknameFor('user-$i')};
      expect(many.length, greaterThan(20)); // reasonably varied
    });
  });

  group('CommunityRepository', () {
    late FakeFirebaseFirestore db;
    late CommunityRepository alice;

    setUp(() {
      db = FakeFirebaseFirestore();
      alice = CommunityRepository(db, 'alice');
    });

    test('publishes anonymously and lists newest first', () async {
      await alice.publish(topic: 'Gratitude', text: 'first');
      await alice.publish(topic: 'Mindfulness', text: ' second ');
      final posts = await alice.watchPosts().first;
      expect(posts.map((p) => p.text), ['second', 'first']);
      expect(posts.first.nickname, nicknameFor('alice'));
      expect(posts.first.authorId, 'alice');
    });

    test('rejects empty, too long or unknown-topic posts', () {
      expect(() => alice.publish(topic: 'Gratitude', text: '  '),
          throwsArgumentError);
      expect(() => alice.publish(topic: 'Gratitude', text: 'x' * 1001),
          throwsArgumentError);
      expect(() => alice.publish(topic: 'Politics', text: 'hi'),
          throwsArgumentError);
    });

    test('hugs toggle once per person', () async {
      await alice.publish(topic: 'Gratitude', text: 'thanks');
      final bob = CommunityRepository(db, 'bob');
      var post = (await bob.watchPosts().first).single;

      await bob.toggleHug(post, hugged: false);
      post = (await bob.watchPosts().first).single;
      expect(post.hugs, 1);
      expect(await bob.watchMyHugs().first, {post.id});

      await bob.toggleHug(post, hugged: true);
      post = (await bob.watchPosts().first).single;
      expect(post.hugs, 0);
      expect(await bob.watchMyHugs().first, isEmpty);
    });

    test('a post hides after 3 reports, one per person', () async {
      await alice.publish(topic: 'Gratitude', text: 'spam spam');
      var post = (await alice.watchPosts().first).single;

      final bob = CommunityRepository(db, 'bob');
      expect(await bob.report(post), isTrue);
      expect(await bob.report(post), isFalse); // already reported

      await CommunityRepository(db, 'carol').report(post);
      post = (await alice.watchPosts().first).single;
      expect(post.reports, 2);

      await CommunityRepository(db, 'dan').report(post);
      expect(await alice.watchPosts().first, isEmpty); // hidden
    });

    test('authors can delete their own posts', () async {
      await alice.publish(topic: 'Gratitude', text: 'bye');
      final post = (await alice.watchPosts().first).single;
      await alice.delete(post);
      expect(await alice.watchPosts().first, isEmpty);
    });

    testWidgets('community page shows my nickname and warns on crisis posts',
        (tester) async {
      final db = FakeFirebaseFirestore();
      await tester.pumpWidget(_signedIn(db, const CommunityPage()));
      await tester.pumpAndSettle();
      expect(find.textContaining(nicknameFor('u1')), findsOneWidget);

      await tester.tap(find.text('Post'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'I want to die');
      await tester.tap(find.text('Publish post'));
      await tester.pumpAndSettle();

      expect(find.text("You don't have to carry this alone"), findsOneWidget);
      await tester.tap(find.text('Post anyway'));
      await tester.pumpAndSettle();
      expect((await db.collection('posts').get()).docs, hasLength(1));
    });
  });

  group('My Garden', () {
    final day1 = DateTime(2026, 11, 14, 10);
    final day2 = DateTime(2026, 11, 15, 10);
    final day4 = DateTime(2026, 11, 17, 10);

    test('points add up and streaks track consecutive days', () {
      var g = const GardenStats();
      g = g.after(Activity.mood, day1);
      g = g.after(Activity.breathing, day1);
      expect(g.points, 4);
      expect(g.streak, 1);

      g = g.after(Activity.journal, day2);
      expect(g.streak, 2);
      expect(g.bestStreak, 2);

      g = g.after(Activity.sleep, day4); // skipped a day
      expect(g.streak, 1);
      expect(g.bestStreak, 2);
      expect(g.counts, {'mood': 1, 'breathing': 1, 'journal': 1, 'sleep': 1});
    });

    test('a plant blooms every 10 points', () {
      const g = GardenStats(points: 23);
      expect(g.plants, 2);
      expect(g.growth, 3);
    });

    test('streak resets when you miss a day', () {
      final g = const GardenStats().after(Activity.mood, day1);
      expect(g.currentStreak(day2), 1); // yesterday still counts
      expect(g.currentStreak(day4), 0);
    });

    test('logging a mood or journal note awards points', () async {
      final db = FakeFirebaseFirestore();
      final repo = WellnessRepository(db, 'u1');
      await repo.addMood(2);
      await repo.addJournal('note');
      // Read directly: the fake's snapshot stream can lag after transactions.
      final g = GardenStats.fromMap(
          (await db.doc('users/u1/garden/stats').get()).data());
      expect(g.points, 3);
      expect(g.counts, {'mood': 1, 'journal': 1});
    });

    test('deleting the account removes garden and my posts', () async {
      final db = FakeFirebaseFirestore();
      final repo = WellnessRepository(db, 'u1');
      await repo.addMood(1);
      await CommunityRepository(db, 'u1').publish(topic: 'Gratitude', text: 'hi');
      await CommunityRepository(db, 'u2').publish(topic: 'Gratitude', text: 'yo');

      await repo.deleteAllData();
      expect((await db.doc('users/u1/garden/stats').get()).exists, isFalse);
      final left = await db.collection('posts').get();
      expect(left.docs.map((d) => d['authorId']), ['u2']);
    });

    testWidgets('garden page shows points, plants and streak', (tester) async {
      final db = FakeFirebaseFirestore();
      await db.doc('users/u1/garden/stats').set(
          const GardenStats(points: 13, streak: 2, bestStreak: 5)
              .after(Activity.mood, DateTime.now())
              .toMap());
      await tester.pumpWidget(_signedIn(db, const GardenPage()));
      await tester.pumpAndSettle();
      expect(find.text('14'), findsOneWidget); // points
      expect(find.text('Growing your next plant'), findsOneWidget);
      expect(find.text('6 points until it blooms'), findsOneWidget);
      await tester.scrollUntilVisible(
          find.textContaining('Best streak: 5'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.textContaining('Best streak: 5'), findsOneWidget);
    });
  });

  group('Dialogs', () {
    // Regression: text boxes used to be disposed while the dialog was still
    // animating closed, which threw "TextEditingController used after dispose".
    testWidgets('text prompt closes cleanly and returns the value',
        (tester) async {
      String? result = 'unset';
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                result = await showTextPrompt(context, title: 'Name', confirmLabel: 'Save'),
            child: const Text('open'),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '  Sas  ');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(result, 'Sas');
      expect(tester.takeException(), isNull);
    });

    testWidgets('password prompts keep spaces', (tester) async {
      String? result;
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await showTextPrompt(context,
                title: 'Pw', confirmLabel: 'OK', obscure: true),
            child: const Text('open'),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), ' pass word ');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(result, ' pass word ');
    });
  });
}
