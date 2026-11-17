import 'package:material_ui/material_ui.dart';

import '../data/community_repository.dart';
import '../data/wellness_repository.dart';
import 'auth_service.dart';
import 'companion_ai.dart';

/// Makes the app's services available to every screen.
///
/// Screens call `AppServices.auth(context)`, `AppServices.repo(context)` or
/// `AppServices.companion(context)`. Tests wrap widgets in [AppServices] with
/// fake Firebase instances and a fake AI.
class AppServices extends InheritedWidget {
  const AppServices({
    super.key,
    required this.authService,
    required this.companionAi,
    required super.child,
  });

  final AuthService authService;
  final CompanionAi companionAi;

  static AppServices _of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppServices>()!;

  static AuthService auth(BuildContext context) => _of(context).authService;

  static CompanionAi companion(BuildContext context) =>
      _of(context).companionAi;

  /// The signed-in user's data. Only call this on screens behind the login.
  static WellnessRepository repo(BuildContext context) {
    final auth = AppServices.auth(context);
    return auth.repositoryFor(auth.currentUser!);
  }

  /// Like [repo], but returns null when there are no services or no user
  /// (for screens such as Breath Control that also work on their own).
  static WellnessRepository? maybeRepo(BuildContext context) {
    final services = context.getInheritedWidgetOfExactType<AppServices>();
    final user = services?.authService.currentUser;
    return user == null ? null : services!.authService.repositoryFor(user);
  }

  /// The shared community, as the signed-in user.
  static CommunityRepository community(BuildContext context) {
    final auth = AppServices.auth(context);
    return auth.communityFor(auth.currentUser!);
  }

  @override
  bool updateShouldNotify(AppServices oldWidget) =>
      authService != oldWidget.authService ||
      companionAi != oldWidget.companionAi;
}
