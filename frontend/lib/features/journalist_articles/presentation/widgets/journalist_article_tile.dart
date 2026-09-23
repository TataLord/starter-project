import 'package:flutter/material.dart';

import '../../domain/entities/journalist_article.dart';
import 'article_status_badge.dart';

/// One row of the "My articles" list.
///
/// It owns no logic: it renders the article it receives and reports what the
/// journalist tapped.
class JournalistArticleTile extends StatelessWidget {
  final JournalistArticleEntity article;
  final ValueChanged<JournalistArticleEntity> onEdit;
  final ValueChanged<JournalistArticleEntity> onPublish;
  final ValueChanged<JournalistArticleEntity> onDelete;

  const JournalistArticleTile({
    super.key,
    required this.article,
    required this.onEdit,
    required this.onPublish,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(article.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.description.isNotEmpty)
            Text(
              article.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 4),
          ArticleStatusBadge(article.status),
        ],
      ),
      isThreeLine: true,
      onTap: () => onEdit(article),
      trailing: PopupMenuButton<String>(
        onSelected: (action) => _onActionSelected(action),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          if (article.isDraft)
            const PopupMenuItem(value: 'publish', child: Text('Publish')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }

  void _onActionSelected(String action) {
    switch (action) {
      case 'edit':
        onEdit(article);
        break;
      case 'publish':
        onPublish(article);
        break;
      case 'delete':
        onDelete(article);
        break;
    }
  }
}
