import 'package:equatable/equatable.dart';

import '../../../domain/entities/article_failures.dart';
import '../../../domain/entities/journalist_article.dart';

enum ArticleEditorStatus {
  editing,
  loading,
  uploadingThumbnail,
  saving,

  /// Saved because the journalist asked for it. The editor closes on this.
  saved,

  /// Saved on its own after the journalist stopped typing. Deliberately a
  /// different state from [saved]: the editor must stay open, or autosaving
  /// would throw the person out of the article every few seconds.
  autosaved,
  failure,
}

/// UI state of the article editor: the article being written, the rules it is
/// currently breaking and what the screen is busy with.
class ArticleEditorState extends Equatable {
  final ArticleEditorStatus status;
  final JournalistArticleEntity article;
  final List<ArticleValidationError> validationErrors;
  final Object ? error;

  const ArticleEditorState({
    this.status = ArticleEditorStatus.editing,
    this.article = const JournalistArticleEntity(),
    this.validationErrors = const [],
    this.error,
  });

  bool get isBusy =>
      status == ArticleEditorStatus.loading ||
      status == ArticleEditorStatus.saving ||
      status == ArticleEditorStatus.uploadingThumbnail;

  bool get isEditingStoredArticle => article.isStored;

  bool get hasThumbnail => article.thumbnailUrl.isNotEmpty;

  ArticleEditorState copyWith({
    ArticleEditorStatus ? status,
    JournalistArticleEntity ? article,
    List<ArticleValidationError> ? validationErrors,
    Object ? error,
    bool clearError = false,
  }) {
    return ArticleEditorState(
      status: status ?? this.status,
      article: article ?? this.article,
      validationErrors: validationErrors ?? this.validationErrors,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object ?> get props => [status, article, validationErrors, error];
}
