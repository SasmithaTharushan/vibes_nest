import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vibes_nest/firebase_options.dart';
import 'package:vibes_nest/pages/home.dart';
import 'package:vibes_nest/pages/welcome_screen.dart';
import 'package:vibes_nest/services/app_services.dart';
import 'package:vibes_nest/services/auth_service.dart';
import 'package:vibes_nest/services/companion_ai.dart';
import 'package:vibes_nest/services/local_migration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(AppServices(
    authService: AuthService(FirebaseAuth.instance, FirebaseFirestore.instance),
    companionAi: GeminiCompanionAi(),
    child: const VibesNestApp(),
  ));
}

class VibesNestApp extends StatelessWidget {
  const VibesNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibes Nest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xff296e48),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

/// Shows the welcome screen when signed out and Home when signed in.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _migratedFor;

  void _migrateOnce(BuildContext context, User user) {
    if (_migratedFor == user.uid) return;
    _migratedFor = user.uid;
    final repo = AppServices.auth(context).repositoryFor(user);
    LocalMigration.run(repo).then((moved) {
      if (moved > 0 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Moved $moved saved items to your account.')));
      }
    }).catchError((Object _) {
      // Not critical: local data stays on the device and we retry next launch.
      _migratedFor = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AppServices.auth(context).authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final user = snapshot.data;
        if (user == null) return const WelcomeScreen();
        _migrateOnce(context, user);
        return HomePage(key: ValueKey(user.uid));
      },
    );
  }
}
