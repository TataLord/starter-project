import 'package:flutter/material.dart';

import '../../domain/entities/article_failures.dart';

/// Turns a failure produced by the business layer into words a journalist can
/// act on.
///
/// The domain reports failures as values (enums and exceptions) and leaves the
/// wording to the presentation layer, which is what this widget provides.
class ArticleFailureText extends StatelessWidget {
  final Object ? failure;

  const ArticleFailureText(this.failure, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      messageFor(failure),
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );
  }

  static String messageFor(Object ? failure) {
    if (failure is ArticleValidationException) {
      return failure.errors.map(messageForValidationError).join('\n');
    }
    if (failure is ThumbnailValidationException) {
      return failure.errors.map(messageForThumbnailError).join('\n');
    }
    if (failure is ArticleNotFoundException) {
      return 'This article no longer exists.';
    }
    if (failure is ArticleNotStoredException) {
      return 'Save the article before publishing it.';
    }
    if (failure == null) {
      return 'Something went wrong.';
    }
    return 'Something went wrong: $failure';
  }

  static String messageForValidationError(ArticleValidationError error) {
    switch (error) {
      case ArticleValidationError.titleRequired:
        return 'The article needs a title.';
      case ArticleValidationError.titleTooLong:
        return 'The title is too long.';
      case ArticleValidationError.descriptionRequired:
        return 'Readers need a short description.';
      case ArticleValidationError.descriptionTooLong:
        return 'The description is too long.';
      case ArticleValidationError.contentRequired:
        return 'The article has no content yet.';
      case ArticleValidationError.thumbnailRequired:
        return 'Add a cover image before publishing.';
      case ArticleValidationError.authorRequired:
        return 'The article has no author.';
      case ArticleValidationError.userRequired:
        return 'The article has no owner.';
    }
  }

  static String messageForThumbnailError(ThumbnailValidationError error) {
    switch (error) {
      case ThumbnailValidationError.emptyFile:
        return 'The selected image is empty.';
      case ThumbnailValidationError.fileTooLarge:
        return 'The image is larger than 5 MB.';
      case ThumbnailValidationError.unsupportedFormat:
        return 'Only jpg, png and webp images are supported.';
    }
  }
}
