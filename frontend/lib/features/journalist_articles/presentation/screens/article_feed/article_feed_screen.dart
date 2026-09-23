import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/journalist_article.dart';
import '../../bloc/article_feed/article_feed_cubit.dart';
import '../../bloc/article_feed/article_feed_state.dart';
import '../../widgets/published_article_tile.dart';

/// Skeleton of a feed of published articles: plain Material widgets wired to
/// [ArticleFeedCubit] so the general community feed and "more from this
/// author" can be exercised end to end before the Figma prototype is built.
///
/// [title] is the only thing that tells the two apart on screen; the cubit
/// provided above this widget is what actually scopes the query (see
/// `AppRoutes._articleFeedScreen`).
class ArticleFeedScreen extends StatelessWidget {
  final String title;

  const ArticleFeedScreen({super.key, this.title = 'Community Articles'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: BlocBuilder<ArticleFeedCubit, ArticleFeedState>(
        builder: (context, state) {
          if (state.status == ArticleFeedStatus.initial || state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ArticleFeedStatus.failure &&
              state.articles.isEmpty) {
            return const Center(child: Text('Could not load articles.'));
          }
          if (state.isEmpty) {
            return const Center(child: Text('No published articles yet.'));
          }

          return ListView.separated(
            itemCount: state.articles.length + (state.hasMore ? 1 : 0),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index >= state.articles.length) {
                return _LoadMoreButton(isLoading: state.isLoadingMore);
              }

              final article = state.articles[index];
              return PublishedArticleTile(
                article: article,
                onTap: () => _openReader(context, article),
              );
            },
          );
        },
      ),
    );
  }

  void _openReader(BuildContext context, JournalistArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleReader', arguments: article);
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool isLoading;

  const _LoadMoreButton({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : OutlinedButton(
                onPressed: () => context.read<ArticleFeedCubit>().loadMore(),
                child: const Text('Load more'),
              ),
      ),
    );
  }
}
