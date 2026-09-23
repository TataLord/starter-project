import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/session/session_cubit.dart';
import '../../bloc/session/session_state.dart';
import '../../widgets/auth_failure_text.dart';

/// Skeleton of the account creation screen.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
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
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Name readers will see (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Repeat password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: state.isBusy ? null : () => _signUp(context),
                child: state.isBusy
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create account'),
              ),
              if (state.status == SessionStatus.failure) ...[
                const SizedBox(height: 12),
                AuthFailureText(state.error),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/SignIn'),
                child: const Text('I already have an account'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _signUp(BuildContext context) {
    context.read<SessionCubit>().signUp(
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          displayName: _displayNameController.text,
        );
  }
}
