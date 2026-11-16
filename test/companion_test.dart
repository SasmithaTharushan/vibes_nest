import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:vibes_nest/pages/chat_screen.dart';
import 'package:vibes_nest/services/app_services.dart';
import 'package:vibes_nest/services/auth_service.dart';
import 'package:vibes_nest/services/companion_ai.dart';
import 'package:vibes_nest/services/crisis_detector.dart';

/// A stand-in for Gemini that records what it was asked.
class FakeCompanion implements CompanionAi {
  FakeCompanion({this.pieces = const ['Hello ', 'there.'], this.fail = false});

  final List<String> pieces;
  final bool fail;
  final List<String> received = [];
  List<ChatTurn> lastHistory = const [];

  @override
  Stream<String> reply({
    required List<ChatTurn> history,
    required String message,
  }) async* {
    received.add(message);
    lastHistory = history;
    if (fail) throw Exception('network down');
    for (final p in pieces) {
      yield p;
    }
  }
}

void main() {
  group('CrisisDetector', () {
    test('detects crisis language, including curly apostrophes', () {
      expect(CrisisDetector.isCrisis('I want to die'), isTrue);
      expect(CrisisDetector.isCrisis('Sometimes I think about SUICIDE'), isTrue);
      expect(CrisisDetector.isCrisis('I don’t want to live anymore'), isTrue);
      expect(CrisisDetector.isCrisis('everyone would be better off without me'),
          isTrue);
    });

    test('does not flag everyday messages', () {
      expect(CrisisDetector.isCrisis('I had a long day at work'), isFalse);
      expect(CrisisDetector.isCrisis('This exam is killing me lol'), isFalse);
    });

    test('suggests the right tool', () {
      expect(CrisisDetector.suggestTool('I feel so anxious'),
          CompanionTool.grounding);
      expect(CrisisDetector.suggestTool('work stress is too much'),
          CompanionTool.breathing);
      expect(CrisisDetector.suggestTool("I can't sleep"), CompanionTool.sleep);
      expect(CrisisDetector.suggestTool('feeling lonely'), CompanionTool.journal);
      expect(CrisisDetector.suggestTool('I want to die'), CompanionTool.crisis);
      expect(CrisisDetector.suggestTool('what a nice day'), isNull);
    });
  });

  group('OfflineCompanion', () {
    test('crisis reply always includes helplines', () {
      expect(OfflineCompanion.replyFor('I want to kill myself'),
          allOf(contains('1926'), contains('119')));
    });

    test('positive message gets an encouraging reply', () {
      expect(OfflineCompanion.replyFor('I feel great today'),
          contains("glad"));
    });
  });

  group('Gemini system prompt', () {
    test('includes safety boundaries and helplines', () {
      const p = GeminiCompanionAi.systemPrompt;
      expect(p, contains('not a therapist'));
      expect(p, contains('1926'));
      expect(p, contains('119'));
      expect(p, contains('Never diagnose'));
    });
  });

  group('ChatScreen', () {
    late FakeFirebaseFirestore db;

    Future<T> pumpChat<T extends CompanionAi>(WidgetTester tester, T ai) async {
      db = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'u1', email: 'u1@example.com'));
      await tester.pumpWidget(AppServices(
        authService: AuthService(auth, db),
        companionAi: ai,
        child: const MaterialApp(home: ChatScreen()),
      ));
      await tester.pumpAndSettle();
      return ai;
    }

    Future<void> send(WidgetTester tester, String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();
    }

    Future<List<Map<String, dynamic>>> saved() async {
      final snap =
          await db.collection('users/u1/chat').orderBy('createdAt').get();
      return snap.docs.map((d) => d.data()).toList();
    }

    testWidgets('shows the AI notice and greeting', (tester) async {
      await pumpChat(tester, FakeCompanion());
      expect(find.textContaining('not a therapist'), findsOneWidget);
      expect(find.textContaining("I'm Nest"), findsOneWidget);
    });

    testWidgets('streams the AI reply and saves both messages', (tester) async {
      final ai = await pumpChat(
          tester, FakeCompanion(pieces: ['That sounds ', 'tough. ', 'Tell me more?']));
      await send(tester, 'Work was hard today');

      expect(ai.received, ['Work was hard today']);
      expect(find.text('That sounds tough. Tell me more?'), findsOneWidget);

      final msgs = await saved();
      expect(msgs.map((m) => m['role']), ['user', 'model']);
      expect(msgs.last['text'], 'That sounds tough. Tell me more?');
    });

    testWidgets('crisis messages never reach the AI', (tester) async {
      final ai = await pumpChat(tester, FakeCompanion());
      await send(tester, 'I want to end my life');

      expect(ai.received, isEmpty);
      expect(find.textContaining('1926'), findsOneWidget);
      expect(find.text('Get help now'), findsOneWidget);
      expect((await saved()).last['tool'], 'crisis');
    });

    testWidgets('adds a tool button under relevant AI replies', (tester) async {
      await pumpChat(tester, FakeCompanion(pieces: ['I hear you.']));
      await send(tester, 'I feel so anxious');
      expect(find.text('I hear you.'), findsOneWidget);
      expect(find.text('Start grounding'), findsOneWidget);
    });

    testWidgets('falls back to offline replies when the AI fails',
        (tester) async {
      await pumpChat(tester, FakeCompanion(fail: true));
      await send(tester, 'I feel so anxious');
      expect(find.textContaining('5-4-3-2-1'), findsOneWidget);
      expect(find.textContaining('offline mode'), findsOneWidget);
    });

    testWidgets('a reply that never arrives times out to offline mode',
        (tester) async {
      await pumpChat(tester, _HangingCompanion());
      await tester.enterText(find.byType(TextField), 'I feel so anxious');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(const Duration(seconds: 31));
      await tester.pumpAndSettle();
      expect(find.textContaining('offline mode'), findsOneWidget);
      expect((await saved()).last['role'], 'model');
    });

    testWidgets('sends earlier messages as context', (tester) async {
      final ai = await pumpChat(tester, FakeCompanion(pieces: ['ok']));
      await send(tester, 'first');
      await send(tester, 'second');
      expect(ai.lastHistory.map((t) => t.text), ['first', 'ok']);
      expect(ai.lastHistory.first.fromUser, isTrue);
    });

    testWidgets('clear chat deletes the conversation', (tester) async {
      await pumpChat(tester, FakeCompanion(pieces: ['ok']));
      await send(tester, 'hello');
      expect(await saved(), hasLength(2));

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear chat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(await saved(), isEmpty);
    });
  });
}

/// An AI that never replies, to test the time limit.
class _HangingCompanion implements CompanionAi {
  @override
  Stream<String> reply({
    required List<ChatTurn> history,
    required String message,
  }) =>
      StreamController<String>().stream;
}
