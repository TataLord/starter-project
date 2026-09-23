import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/entities/auth_failures.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/get_current_user.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/sign_in.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/sign_up.dart';
import 'package:news_app_clean_architecture/features/authentication/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/authentication/presentation/bloc/session/session_state.dart';

import '../../../../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late SessionCubit cubit;

  setUp(() {
    repository = FakeAuthRepository();
    cubit = SessionCubit(
      GetCurrentUserUseCase(repository),
      SignUpUseCase(repository),
      SignInUseCase(repository),
      SignOutUseCase(repository),
    );
  });

  tearDown(() => cubit.close());

  test('starts signed out when no session survived', () async {
    await cubit.loadSession();

    expect(cubit.state.status, SessionStatus.signedOut);
    expect(cubit.state.isSignedIn, isFalse);
  });

  test('restores a session that was still alive', () async {
    repository.currentUserResult =
        const DataSuccess(FakeAuthRepository.anyUser);

    await cubit.loadSession();

    expect(cubit.state.status, SessionStatus.signedIn);
    expect(cubit.state.user?.id, 'journalist-1');
  });

  test('treats a failed session lookup as nobody being signed in', () async {
    repository.currentUserResult = const DataFailed(FormatException('boom'));

    await cubit.loadSession();

    expect(cubit.state.status, SessionStatus.signedOut);
  });

  test('signs in and holds on to the user', () async {
    await cubit.signIn(email: 'alex@example.com', password: 'a-good-password');

    expect(cubit.state.status, SessionStatus.signedIn);
    expect(cubit.state.user, FakeAuthRepository.anyUser);
  });

  test('reports the rules the credentials break, staying signed out',
      () async {
    await cubit.signUp(
      email: 'alex@example.com',
      password: 'short',
      confirmPassword: 'short',
    );

    expect(cubit.state.status, SessionStatus.failure);
    expect(
      cubit.state.validationErrors,
      contains(CredentialsValidationError.passwordTooShort),
    );
    expect(cubit.state.isSignedIn, isFalse);
    expect(repository.signUpCallCount, 0);
  });

  test('signing out drops the user', () async {
    await cubit.signIn(email: 'alex@example.com', password: 'a-good-password');

    await cubit.signOut();

    expect(cubit.state.status, SessionStatus.signedOut);
    expect(cubit.state.user, isNull);
  });
}
