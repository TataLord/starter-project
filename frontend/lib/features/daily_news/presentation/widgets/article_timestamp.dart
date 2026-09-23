import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Shows when an article was published, the way a reader thinks about it.
///
/// Recent news is relative ("3h ago") because that is what tells a reader
/// whether it is still current; anything older than a week is an absolute
/// date, because "312h ago" tells them nothing.
///
/// The News API hands `publishedAt` over as a string, so parsing failures are
/// a real case and are handled by showing nothing rather than a broken date.
class ArticleTimestamp extends StatelessWidget {
  final String ? rawDate;
  final TextStyle ? style;

  const ArticleTimestamp({super.key, required this.rawDate, this.style});

  @override
  Widget build(BuildContext context) {
    final label = format(rawDate);

    if (label.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(label, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
  }

  static String format(String ? rawDate, {DateTime ? now}) {
    if (rawDate == null || rawDate.isEmpty) {
      return '';
    }

    final published = DateTime.tryParse(rawDate);
    if (published == null) {
      return '';
    }

    final elapsed = (now ?? DateTime.now()).difference(published);

    if (elapsed.inMinutes < 1) {
      return 'Just now';
    }
    if (elapsed.inHours < 1) {
      return '${elapsed.inMinutes}m ago';
    }
    if (elapsed.inHours < 24) {
      return '${elapsed.inHours}h ago';
    }
    if (elapsed.inDays < 7) {
      return '${elapsed.inDays}d ago';
    }

    return DateFormat('MMM d, y').format(published);
  }
}
