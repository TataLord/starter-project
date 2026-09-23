import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/article_status.dart';
import '../../../domain/entities/journalist_article.dart';
import '../../bloc/my_articles/my_articles_cubit.dart';
import '../../bloc/my_articles/my_articles_state.dart';
import '../../widgets/article_failure_text.dart';
import '../../widgets/journalist_article_tile.dart';

/// Skeleton of the "My articles" screen: plain Material widgets wired to
/// [MyArticlesCubit] so the feature can be exercised end to end. The visual
/// design comes later, from the Figma prototype.
class MyArticlesScreen extends StatelessWidget {
  const MyArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Articles')),
      body: Column(
        children: [
          const _ArticleSearchField(),
          const _StatusFilterBar(),
          const Divider(height: 1),
          Expanded(child: _buildBody(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<MyArticlesCubit, MyArticlesState>(
      listenWhen: (previous, current) => current.error != previous.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ArticleFailureText.messageFor(state.error))),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.isEmpty) {
          return const Center(child: Text('No articles yet. Write one!'));
        }
        if (state.status == MyArticlesStatus.failure && state.articles.isEmpty) {
          return Center(child: ArticleFailureText(state.error));
        }

        return ListView.separated(
          itemCount: state.articles.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final article = state.articles[index];
            return JournalistArticleTile(
              article: article,
              onEdit: (article) => _openEditor(context, article),
              onPublish: (article) =>
                  context.read<MyArticlesCubit>().publishArticle(article),
              onDelete: (article) => _confirmDelete(context, article),
            );
          },
        );
      },
    );
  }

  Future<void> _openEditor(
    BuildContext context, [
    JournalistArticleEntity ? article,
  ]) async {
    final cubit = context.read<MyArticlesCubit>();

    await Navigator.pushNamed(
      context,
      '/ArticleEditor',
      arguments: article?.id,
    );

    return cubit.loadArticles();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    JournalistArticleEntity article,
  ) async {
    final cubit = context.read<MyArticlesCubit>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete article'),
        content: Text('"${article.title}" will be deleted permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      return cubit.deleteArticle(article.id!);
    }
  }
}

class _ArticleSearchField extends StatelessWidget {
  const _ArticleSearchField();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        decoration: const InputDecoration(
          isDense: true,
          prefixIcon: Icon(Icons.search),
          hintText: 'Search in my articles',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (query) => context.read<MyArticlesCubit>().search(query),
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyArticlesCubit, MyArticlesState>(
      buildWhen: (previous, current) =>
          previous.statusFilter != current.statusFilter,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _filterChip(context, label: 'All', status: null, state: state),
              const SizedBox(width: 8),
              _filterChip(
                context,
                label: 'Drafts',
                status: ArticleStatus.draft,
                state: state,
              ),
              const SizedBox(width: 8),
              _filterChip(
                context,
                label: 'Published',
                status: ArticleStatus.published,
                state: state,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(
    BuildContext context, {
    required String label,
    required ArticleStatus ? status,
    required MyArticlesState state,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: state.statusFilter == status,
      onSelected: (_) => context.read<MyArticlesCubit>().filterByStatus(status),
    );
  }
}
