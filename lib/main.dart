import 'package:material_ui/material_ui.dart';
import 'package:vibes_nest/pages/home.dart';
import 'package:vibes_nest/pages/welcome_screen.dart';
import 'package:vibes_nest/services/local_profile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final signedIn = await LocalProfile.isSignedIn();
  runApp(VibesNestApp(signedIn: signedIn));
}

class VibesNestApp extends StatelessWidget {
  const VibesNestApp({super.key, required this.signedIn});

  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibes Nest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xff296e48),
        useMaterial3: true,
      ),
      home: signedIn ? const HomePage() : const WelcomeScreen(),
    );
  }
}
