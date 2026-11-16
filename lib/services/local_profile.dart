import 'package:shared_preferences/shared_preferences.dart';

/// Stores the signed-in user's basic details on the device.
///
/// This is a temporary stand-in until Firebase Authentication is added in
/// Phase 2. Nothing here is a real security boundary.
class LocalProfile {
  static const _nameKey = 'profile_name';
  static const _emailKey = 'profile_email';
  static const _signedInKey = 'profile_signed_in';

  static Future<void> signIn({required String email, String? name}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email.trim());
    if (name != null && name.trim().isNotEmpty) {
      await prefs.setString(_nameKey, name.trim());
    } else if (!prefs.containsKey(_nameKey)) {
      // Fall back to the part of the email before "@".
      await prefs.setString(_nameKey, email.split('@').first);
    }
    await prefs.setBool(_signedInKey, true);
  }

  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_signedInKey, false);
  }

  static Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_signedInKey) ?? false;
  }

  static Future<String> name() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? 'Friend';
  }

  static Future<String> email() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey) ?? '';
  }
}
