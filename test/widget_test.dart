import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vibes_nest/main.dart';
import 'package:vibes_nest/pages/breath_control_page.dart';
import 'package:vibes_nest/pages/chat_screen.dart';
import 'package:vibes_nest/pages/stay_calm_page.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Signed-out users see the welcome screen', (tester) async {
    await tester.pumpWidget(const VibesNestApp(signedIn: false));
    await tester.pumpAndSettle();
    expect(find.textContaining('Welcome to Vibes Nest', findRichText: true), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });

  testWidgets('Stay Calm walks through all five grounding steps',
      (tester) async {
    await tester.pumpWidget(_wrap(const StayCalmPage()));
    expect(find.text('Name 5 things you can SEE'), findsOneWidget);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Next'));
      await tester.pump();
    }
    expect(find.text('Name 1 thing you can TASTE'), findsOneWidget);

    await tester.tap(find.text('Finish'));
    await tester.pump();
    expect(find.text('Well done.'), findsOneWidget);
  });

  testWidgets('Breath Control starts and stops', (tester) async {
    await tester.pumpWidget(_wrap(const BreathControlPage()));
    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.text('Breathe in'), findsOneWidget);

    await tester.tap(find.text('Stop'));
    await tester.pump();
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('Chat routes crisis messages to help', (tester) async {
    await tester.pumpWidget(_wrap(const ChatScreen()));
    await tester.enterText(find.byType(TextField), 'I want to die');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    expect(find.textContaining('1926'), findsOneWidget);
    expect(find.text('Get help now'), findsOneWidget);
  });

  testWidgets('Chat suggests grounding for anxiety', (tester) async {
    await tester.pumpWidget(_wrap(const ChatScreen()));
    await tester.enterText(find.byType(TextField), 'I feel so anxious');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    expect(find.text('Start grounding'), findsOneWidget);
  });
}
