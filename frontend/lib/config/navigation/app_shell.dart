import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/authentication/presentation/bloc/session/session_cubit.dart';
import '../../features/authentication/presentation/screens/account/account_screen.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';
import '../../features/journalist_articles/domain/use_cases/get_published_articles.dart';
import '../../features/journalist_articles/presentation/bloc/article_feed/article_feed_cubit.dart';
import '../../features/journalist_articles/presentation/screens/article_feed/article_feed_screen.dart';
import '../../injection_container.dart';
import '../theme/design_tokens.dart';

/// The four tabs the app is organised around.
///
/// It replaces the row of unlabelled icons the app bar used to carry: every
/// destination now says what it is, which is the difference between an app
/// somebody can learn and one they have to be taught.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const List<_Destination> _destinations = [
    _Destination(
      label: 'NEWS',
      icon: Icons.article_outlined,
      selectedIcon: Icons.article,
    ),
    _Destination(
      label: 'COMMUNITY',
      icon: Icons.forum_outlined,
      selectedIcon: Icons.forum,
    ),
    _Destination(
      label: 'SAVED',
      icon: Icons.bookmark_border,
      selectedIcon: Icons.bookmark,
    ),
    _Destination(
      label: 'ACCOUNT',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const DailyNews(),
          // Composed here, as in AppRoutes, so the screen never reaches for
          // the injection container itself.
          BlocProvider<ArticleFeedCubit>(
            create: (_) =>
                ArticleFeedCubit(sl<GetPublishedArticlesUseCase>())..loadFeed(),
            child: const ArticleFeedScreen(),
          ),
          const SavedArticles(),
          const AccountScreen(),
        ],
      ),
      // Writing is offered from the two reading tabs. It is absent from Saved
      // and Account, where it would have nothing to do with what is on screen.
      floatingActionButton: _currentIndex <= 1 ? const WriteButton() : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: [
          for (final destination in _destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}

/// The way into the editor, from anywhere a person is reading.
///
/// Without an account it opens the invitation sheet instead of failing: the
/// answer to "can I write?" is never a silent nothing.
class WriteButton extends StatelessWidget {
  const WriteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _onPressed(context),
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.edit_outlined, size: 20),
      label: Text(
        'Write',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontSize: 15,
            ),
      ),
    );
  }

  void _onPressed(BuildContext context) {
    final isSignedIn = context.read<SessionCubit>().state.isSignedIn;

    if (isSignedIn) {
      Navigator.pushNamed(context, '/ArticleEditor');
      return;
    }

    Navigator.pushNamed(context, '/SignIn');
  }
}

class _Destination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _Destination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
