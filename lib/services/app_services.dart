import 'package:material_ui/material_ui.dart';

import '../data/wellness_repository.dart';
import 'auth_service.dart';

/// Makes the app's services available to every screen.
///
/// Screens call `AppServices.auth(context)` or `AppServices.repo(context)`.
/// Tests wrap widgets in [AppServices] with fake Firebase instances.
class AppServices extends InheritedWidget {
  const AppServices({super.key, required this.authService, required super.child});

  final AuthService authService;

  static AuthService auth(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AppServices>()!
      .authService;

  /// The signed-in user's data. Only call this on screens behind the login.
  static WellnessRepository repo(BuildContext context) {
    final auth = AppServices.auth(context);
    return auth.repositoryFor(auth.currentUser!);
  }

  @override
  bool updateShouldNotify(AppServices oldWidget) =>
      authService != oldWidget.authService;
}
