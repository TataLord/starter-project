import 'package:firebase_auth/firebase_auth.dart';

/// The only class in the app that talks to Firebase Authentication.
///
/// It throws `FirebaseAuthException` straight from the SDK: turning provider
/// errors into the domain's own failures is the repository's job, not this
/// one's.
class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;

  const FirebaseAuthService(this._firebaseAuth);

  User ? get currentUser => _firebaseAuth.currentUser;

  /// Creates the account and sets its display name.
  ///
  /// It deliberately does not call `User.reload()` afterwards: reloading has
  /// been seen to never complete on Android, which left the sign-up screen
  /// spinning forever over an account that had in fact been created. The
  /// caller already knows the name it asked for, so re-reading it buys
  /// nothing.
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw StateError('Firebase created an account but returned no user.');
    }

    if (displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
    }

    return user;
  }

  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user!;
  }

  Future<void> signOut() => _firebaseAuth.signOut();

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
