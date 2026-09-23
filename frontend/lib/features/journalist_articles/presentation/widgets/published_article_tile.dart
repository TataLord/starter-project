import 'package:flutter/material.dart';

import '../../domain/entities/journalist_article.dart';

/// One row of a feed of published articles, as any reader sees it.
///
/// Unlike [JournalistArticleTile] (the author's own list, with edit/publish/
/// delete actions), this tile owns no author action: it only renders the
/// article and reports a tap.
class PublishedArticleTile extends StatelessWidget {
  final JournalistArticleEntity article;
  final VoidCallback onTap;

  const PublishedArticleTile({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(article.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('By ${article.author}'),
          if (article.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              article.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      isThreeLine: article.description.isNotEmpty,
      onTap: onTap,
    );
  }
}
