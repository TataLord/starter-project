import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/password_reset/password_reset_cubit.dart';
import '../../bloc/password_reset/password_reset_state.dart';
import '../../widgets/auth_failure_text.dart';

/// Skeleton of the "forgot my password" screen.
///
/// One screen, because the reset itself happens on the page Firebase emails a
/// link to, not in the app (see `docs/DECISIONS.md` decision #32).
class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: BlocBuilder<PasswordResetCubit, PasswordResetState>(
        builder: (context, state) {
          if (state.wasSent) {
            return const _ResetEmailSentMessage();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Enter the email you signed up with and we will send you a '
                'link to choose a new password.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: state.isSending
                    ? null
                    : () => context
                        .read<PasswordResetCubit>()
                        .requestReset(_emailController.text),
                child: state.isSending
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send reset link'),
              ),
              if (state.status == PasswordResetStatus.failure) ...[
                const SizedBox(height: 12),
                AuthFailureText(state.error),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ResetEmailSentMessage extends StatelessWidget {
  const _ResetEmailSentMessage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mark_email_read_outlined, size: 48),
          const SizedBox(height: 16),
          // Worded so it says nothing about whether that address has an
          // account: the use case promises not to leak that.
          const Text(
            'If that email has an account, a reset link is on its way. '
            'Open it to choose a new password, then come back and sign in.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to sign in'),
          ),
        ],
      ),
    );
  }
}
