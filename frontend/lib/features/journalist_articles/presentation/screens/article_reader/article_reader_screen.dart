import 'package:flutter/material.dart';

import '../../../domain/entities/journalist_article.dart';

/// Skeleton of the screen a reader lands on after tapping a published
/// article, plain Material widgets on purpose (see `ArticleFeedScreen`).
///
/// The entry point to "more from this author" lives here: it hands off to
/// `/ArticleFeed` scoped to [article.userId], instead of embedding a second
/// `ArticleFeedCubit` in this screen, which would require importing the
/// injection container from the presentation layer (decision #12 in
/// `docs/DECISIONS.md`). Composing that cubit stays the job of `AppRoutes`.
class ArticleReaderScreen extends StatelessWidget {
  final JournalistArticleEntity article;

  const ArticleReaderScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article.author)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(article.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('By ${article.author}'),
          const SizedBox(height: 16),
          Text(article.content),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _openMoreFromAuthor(context),
            child: Text('More from ${article.author}'),
          ),
        ],
      ),
    );
  }

  void _openMoreFromAuthor(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/ArticleFeed',
      arguments: {
        'authorId': article.userId,
        'excludeArticleId': article.id,
        'title': 'More from ${article.author}',
      },
    );
  }
}
