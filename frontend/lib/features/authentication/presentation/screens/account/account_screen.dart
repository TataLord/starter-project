import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/session/session_cubit.dart';
import '../../bloc/session/session_state.dart';

/// Skeleton of the account screen: who is signed in, and the way out.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: BlocConsumer<SessionCubit, SessionState>(
        listenWhen: (previous, current) =>
            previous.isSignedIn != current.isSignedIn,
        listener: (context, state) {
          if (!state.isSignedIn) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final user = state.user;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(user.authorName),
                subtitle: Text(user.email),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.edit_note),
                title: const Text('My articles'),
                onTap: () => Navigator.pushNamed(context, '/MyArticles'),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                onTap: state.isBusy
                    ? null
                    : () => context.read<SessionCubit>().signOut(),
              ),
            ],
          );
        },
      ),
    );
  }
}
