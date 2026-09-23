import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/session/session_cubit.dart';
import '../../bloc/session/session_state.dart';
import '../../widgets/auth_failure_text.dart';

/// Skeleton of the sign in screen, plain Material widgets wired to
/// [SessionCubit] (same intent as decision #14: the Figma design comes later).
///
/// Reaching this screen is never mandatory to read the app; it is shown when
/// somebody asks for their account, or tries to do something that needs one.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: BlocConsumer<SessionCubit, SessionState>(
        listenWhen: (previous, current) =>
            previous.isSignedIn != current.isSignedIn,
        listener: (context, state) {
          if (state.isSignedIn) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: state.isBusy ? null : () => _signIn(context),
                child: state.isBusy
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign in'),
              ),
              if (state.status == SessionStatus.failure) ...[
                const SizedBox(height: 12),
                AuthFailureText(state.error),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/PasswordReset'),
                child: const Text('I forgot my password'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/SignUp'),
                child: const Text('Create an account'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _signIn(BuildContext context) {
    context.read<SessionCubit>().signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }
}
