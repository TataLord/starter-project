import 'package:flutter/material.dart';

import '../../domain/entities/auth_failures.dart';
import '../../domain/entities/credentials_rules.dart';

/// Turns an authentication failure into words the person can act on.
///
/// The domain reports failures as values and leaves the wording here, the
/// same way [ArticleFailureText] does for articles.
class AuthFailureText extends StatelessWidget {
  final Object ? failure;

  const AuthFailureText(this.failure, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      messageFor(failure),
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );
  }

  static String messageFor(Object ? failure) {
    if (failure is CredentialsValidationException) {
      return failure.errors.map(messageForValidationError).join('\n');
    }
    if (failure is EmailAlreadyRegisteredException) {
      return 'That email already has an account. Sign in instead.';
    }
    if (failure is InvalidCredentialsException) {
      return 'That email and password do not match an account.';
    }
    if (failure is NotSignedInException) {
      return 'Sign in to continue.';
    }
    if (failure is TooManyAttemptsException) {
      return 'Too many attempts. Try again in a few minutes.';
    }
    if (failure == null) {
      return 'Something went wrong.';
    }
    return 'Something went wrong: $failure';
  }

  static String messageForValidationError(CredentialsValidationError error) {
    switch (error) {
      case CredentialsValidationError.emailRequired:
        return 'Enter your email.';
      case CredentialsValidationError.emailMalformed:
        return 'That does not look like an email address.';
      case CredentialsValidationError.passwordRequired:
        return 'Enter your password.';
      case CredentialsValidationError.passwordTooShort:
        return 'Use at least ${CredentialsRules.passwordMinLength} characters.';
      case CredentialsValidationError.passwordsDoNotMatch:
        return 'The two passwords are different.';
    }
  }
}
