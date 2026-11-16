import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/wellness_repository.dart';

/// Thrown with a message that is safe to show to the user.
class AuthFailure implements Exception {
  AuthFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Wraps Firebase Authentication and turns its errors into friendly messages.
class AuthService {
  AuthService(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  String get displayName {
    final user = _auth.currentUser;
    final name = user?.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = user?.email;
    return email != null ? email.split('@').first : 'Friend';
  }

  WellnessRepository repositoryFor(User user) =>
      WellnessRepository(_db, user.uid);

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) =>
      _guard(() async {
        final cred = await _auth.createUserWithEmailAndPassword(
            email: email.trim(), password: password);
        final user = cred.user!;
        await user.updateDisplayName(name.trim());
        await WellnessRepository(_db, user.uid)
            .saveProfile(name: name.trim(), email: email.trim());
        // Not required to use the app, but helps with password recovery.
        await user.sendEmailVerification();
        await user.reload();
      });

  Future<void> signIn({required String email, required String password}) =>
      _guard(() => _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password));

  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  Future<void> updateName(String name) => _guard(() async {
        final user = _auth.currentUser!;
        await user.updateDisplayName(name.trim());
        await WellnessRepository(_db, user.uid)
            .saveProfile(name: name.trim(), email: user.email ?? '');
        await user.reload();
      });

  Future<void> signOut() => _auth.signOut();

  /// Deletes the user's data and account. Firebase requires a recent login for
  /// this, so we ask for the password again first.
  Future<void> deleteAccount({required String password}) => _guard(() async {
        final user = _auth.currentUser!;
        final cred = EmailAuthProvider.credential(
            email: user.email!, password: password);
        await user.reauthenticateWithCredential(cred);
        await WellnessRepository(_db, user.uid).deleteAllData();
        await user.delete();
      });

  Future<void> _guard(Future<Object?> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(messageFor(e.code));
    } on FirebaseException catch (e) {
      throw AuthFailure(e.message ?? 'Something went wrong. Please try again.');
    }
  }

  static String messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address doesn\'t look right.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists for that email. Try signing in.';
      case 'weak-password':
        return 'Please choose a stronger password (at least 8 characters).';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'requires-recent-login':
        return 'For your security, please sign in again and retry.';
      default:
        return 'Something went wrong ($code). Please try again.';
    }
  }
}
