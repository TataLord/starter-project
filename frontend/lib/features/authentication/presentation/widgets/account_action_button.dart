import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/session/session_cubit.dart';
import '../bloc/session/session_state.dart';

/// App bar entry point to the account, for screens that are open to everyone.
///
/// It exists so a screen can offer an account without knowing anything about
/// sessions: `DailyNews` only places this widget, and this widget is the one
/// that reads [SessionCubit] and decides where the tap goes.
class AccountActionButton extends StatelessWidget {
  final Color color;

  const AccountActionButton({super.key, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      buildWhen: (previous, current) =>
          previous.isSignedIn != current.isSignedIn,
      builder: (context, state) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            state.isSignedIn ? '/Account' : '/SignIn',
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              state.isSignedIn ? Icons.account_circle : Icons.person_outline,
              color: color,
            ),
          ),
        );
      },
    );
  }
}
