import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/feed_states.dart';
import '../../widgets/news_article_card.dart';

/// The front door: world news, readable with no account.
///
/// The first article is given the lead treatment and the rest are compact
/// rows, so the feed has a shape instead of being a wall of equal cards.
class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        titleSpacing: AppSpacing.xl,
        toolbarHeight: 72,
        title: Text(
          'Daily News',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
      body: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
        builder: (context, state) {
          if (state is RemoteArticlesLoading) {
            return const FeedLoadingList();
          }
          if (state is RemoteArticlesError) {
            return FeedErrorMessage(
              message: 'We could not load the news.',
              onRetry: () => context
                  .read<RemoteArticlesBloc>()
                  .add(const GetArticles()),
            );
          }
          if (state is RemoteArticlesDone) {
            final articles = state.articles ?? const <ArticleEntity>[];

            if (articles.isEmpty) {
              return const FeedEmptyMessage(
                icon: Icons.newspaper_outlined,
                title: 'No news right now',
                message: 'Check back in a little while.',
              );
            }

            return _NewsList(articles: articles);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NewsList extends StatelessWidget {
  final List<ArticleEntity> articles;

  const _NewsList({required this.articles});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<RemoteArticlesBloc>().add(const GetArticles()),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          // Room for the floating "Write" button to sit over the list without
          // ever covering the last article.
          AppSpacing.huge * 2,
        ),
        itemCount: articles.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final article = articles[index];

          if (index == 0) {
            return LeadArticleCard(
              article: article,
              onTap: () => _openArticle(context, article),
            );
          }

          return CompactArticleCard(
            article: article,
            onTap: () => _openArticle(context, article),
          );
        },
      ),
    );
  }

  void _openArticle(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }
}
