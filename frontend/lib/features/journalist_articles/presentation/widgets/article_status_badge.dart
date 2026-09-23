import 'package:flutter/material.dart';

import '../../domain/entities/article_status.dart';

/// Shows whether an article is still private or already public.
class ArticleStatusBadge extends StatelessWidget {
  final ArticleStatus status;

  const ArticleStatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDraft = status == ArticleStatus.draft;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isDraft ? Colors.orange.shade100 : Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isDraft ? 'Draft' : 'Published',
        style: TextStyle(
          fontSize: 12,
          color: isDraft ? Colors.orange.shade900 : Colors.green.shade900,
        ),
      ),
    );
  }
}
