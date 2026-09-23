import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/auth_failures.dart';
import '../../../domain/params/sign_in_params.dart';
import '../../../domain/params/sign_up_params.dart';
import '../../../domain/use_cases/get_current_user.dart';
import '../../../domain/use_cases/sign_in.dart';
import '../../../domain/use_cases/sign_out.dart';
import '../../../domain/use_cases/sign_up.dart';
import 'session_state.dart';

/// Owns the answer to "who is using the app".
///
/// It is a single instance for the whole app: the account button, the route
/// guards and the article cubits all read the same session. It owns no rule
/// of its own; whether credentials are acceptable is decided by the use
/// cases.
class SessionCubit extends Cubit<SessionState> {
  final GetCurrentUserUseCase _getCurrentUser;
  final SignUpUseCase _signUp;
  final SignInUseCase _signIn;
  final SignOutUseCase _signOut;

  SessionCubit(
    this._getCurrentUser,
    this._signUp,
    this._signIn,
    this._signOut,
  ) : super(const SessionState());

  /// Looks up whether a session survived from a previous run.
  Future<void> loadSession() async {
    final result = await _getCurrentUser(const NoParams());

    if (result is DataSuccess<AppUserEntity ?>) {
      _emitSignedInOrOut(result.data);
      return;
    }

    // Failing to read the session is not worth blocking a reader over: the
    // app simply behaves as if nobody were signed in.
    emit(const SessionState(status: SessionStatus.signedOut));
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String confirmPassword,
    String displayName = '',
  }) async {
    emit(state.copyWith(status: SessionStatus.busy, clearError: true));

    final result = await _signUp(SignUpParams(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      displayName: displayName,
    ));

    _emitAuthResult(result);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: SessionStatus.busy, clearError: true));

    final result = await _signIn(SignInParams(
      email: email,
      password: password,
    ));

    _emitAuthResult(result);
  }

  Future<void> signOut() async {
    emit(state.copyWith(status: SessionStatus.busy, clearError: true));

    final result = await _signOut(const NoParams());

    if (result is DataSuccess) {
      emit(const SessionState(status: SessionStatus.signedOut));
      return;
    }

    _emitFailure(result.error);
  }

  void _emitAuthResult(DataState<AppUserEntity> result) {
    if (result is DataSuccess<AppUserEntity>) {
      _emitSignedInOrOut(result.data);
      return;
    }

    _emitFailure(result.error);
  }

  void _emitSignedInOrOut(AppUserEntity ? user) {
    emit(SessionState(
      status: user == null ? SessionStatus.signedOut : SessionStatus.signedIn,
      user: user,
    ));
  }

  void _emitFailure(Object ? error) {
    emit(state.copyWith(
      status: SessionStatus.failure,
      error: error,
      validationErrors: error is CredentialsValidationException
          ? error.errors
          : const <CredentialsValidationError>[],
    ));
  }
}
