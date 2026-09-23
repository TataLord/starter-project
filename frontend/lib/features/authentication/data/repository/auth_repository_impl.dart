import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_failures.dart';
import '../../domain/repository/auth_repository.dart';
import '../data_sources/remote/firebase_auth_service.dart';
import '../models/app_user_model.dart';

/// Firebase Authentication implementation of [AuthRepository].
///
/// This is where `FirebaseAuthException` stops existing: every provider error
/// is translated into one of the domain's own failures, so nothing above this
/// class has to know which provider is behind it.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;

  const AuthRepositoryImpl(this._authService);

  @override
  Future<DataState<AppUserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _guard(() async {
      final user = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      final registered = AppUserModel.fromFirebaseUser(user).toEntity();

      // `updateDisplayName` does not necessarily refresh the cached user, and
      // re-reading it is what used to hang, so the name just written wins.
      return displayName.isEmpty
          ? registered
          : registered.copyWith(displayName: displayName);
    });
  }

  @override
  Future<DataState<AppUserEntity>> signIn({
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final user = await _authService.signIn(email: email, password: password);

      return AppUserModel.fromFirebaseUser(user).toEntity();
    });
  }

  @override
  Future<DataState<void>> signOut() {
    return _guard(() => _authService.signOut());
  }

  @override
  Future<DataState<AppUserEntity ?>> getCurrentUser() {
    return _guard(() async {
      final user = _authService.currentUser;

      return user == null
          ? null
          : AppUserModel.fromFirebaseUser(user).toEntity();
    });
  }

  @override
  Future<DataState<void>> requestPasswordReset(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);

      return const DataSuccess(null);
    } on FirebaseAuthException catch (error) {
      // An address nobody uses is reported as a success on purpose: the
      // contract promises the app cannot be used to discover who is
      // registered (see AuthRepository.requestPasswordReset).
      if (error.code == 'user-not-found') {
        return const DataSuccess(null);
      }

      return DataFailed(_toDomainFailure(error));
    } catch (error) {
      return DataFailed(error);
    }
  }

  /// Runs [operation] and guarantees a [DataState] comes back.
  ///
  /// The broad `catch` is deliberate. Letting anything other than a
  /// `FirebaseAuthException` escape does not surface an error, it makes the
  /// caller's `await` never complete: that is what left the sign-up screen
  /// spinning over an account Firebase had already created. A repository owes
  /// its caller an answer, including "something unexpected happened".
  Future<DataState<T>> _guard<T>(Future<T> Function() operation) async {
    try {
      return DataSuccess(await operation());
    } on FirebaseAuthException catch (error) {
      return DataFailed(_toDomainFailure(error));
    } catch (error) {
      return DataFailed(error);
    }
  }

  /// Maps a Firebase error code onto the failure the domain understands.
  ///
  /// `invalid-credential` is what recent Firebase versions return instead of
  /// `wrong-password`/`user-not-found` when email enumeration protection is
  /// on, which is exactly the distinction [InvalidCredentialsException]
  /// refuses to make.
  Object _toDomainFailure(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return const EmailAlreadyRegisteredException();
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-email':
      case 'user-disabled':
        return const InvalidCredentialsException();
      case 'weak-password':
        return const CredentialsValidationException(
          [CredentialsValidationError.passwordTooShort],
        );
      case 'too-many-requests':
        return const TooManyAttemptsException();
      default:
        return error;
    }
  }
}
