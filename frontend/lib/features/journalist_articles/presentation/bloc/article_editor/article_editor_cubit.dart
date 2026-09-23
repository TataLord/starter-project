import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../../domain/entities/article_failures.dart';
import '../../../domain/entities/article_status.dart';
import '../../../domain/entities/article_thumbnail.dart';
import '../../../domain/entities/journalist_article.dart';
import '../../../domain/params/create_article_params.dart';
import '../../../domain/params/get_article_by_id_params.dart';
import '../../../domain/params/publish_article_params.dart';
import '../../../domain/params/update_article_params.dart';
import '../../../domain/params/upload_article_thumbnail_params.dart';
import '../../../domain/use_cases/create_article.dart';
import '../../../domain/use_cases/get_article_by_id.dart';
import '../../../domain/use_cases/publish_article.dart';
import '../../../domain/use_cases/update_article.dart';
import '../../../domain/use_cases/upload_article_thumbnail.dart';
import 'article_editor_state.dart';

/// Drives the screen where a journalist writes a new article or edits one of
/// their stored ones.
///
/// Whether an article may be saved as a draft or published is decided by the
/// use cases; the cubit only reports what they answered.
class ArticleEditorCubit extends Cubit<ArticleEditorState> {
  final GetArticleByIdUseCase _getArticleById;
  final CreateArticleUseCase _createArticle;
  final UpdateArticleUseCase _updateArticle;
  final PublishArticleUseCase _publishArticle;
  final UploadArticleThumbnailUseCase _uploadThumbnail;

  final String journalistId;
  final String journalistName;

  /// How long to wait after the last edit before autosaving a draft.
  final Duration autosaveDelay;

  Timer ? _autosaveTimer;

  ArticleEditorCubit(
    this._getArticleById,
    this._createArticle,
    this._updateArticle,
    this._publishArticle,
    this._uploadThumbnail, {
    required this.journalistId,
    required this.journalistName,
    this.autosaveDelay = const Duration(seconds: 2),
  }) : super(const ArticleEditorState());

  /// Prepares the editor for an article that does not exist yet.
  void startNewArticle() {
    emit(ArticleEditorState(
      article: JournalistArticleEntity(
        author: journalistName,
        userId: journalistId,
      ),
    ));
  }

  /// Loads a stored article so the journalist can keep working on it.
  Future<void> loadArticle(String articleId) async {
    emit(state.copyWith(status: ArticleEditorStatus.loading, clearError: true));

    final result = await _getArticleById(GetArticleByIdParams(articleId));

    if (result is DataSuccess<JournalistArticleEntity>) {
      emit(ArticleEditorState(article: result.data!));
      return;
    }

    emit(state.copyWith(
      status: ArticleEditorStatus.failure,
      error: result.error,
    ));
  }

  void titleChanged(String title) => _editArticle(title: title);

  void descriptionChanged(String description) =>
      _editArticle(description: description);

  void contentChanged(String content) => _editArticle(content: content);

  /// Uploads the picked image and attaches its url to the article.
  Future<void> uploadThumbnail(ArticleThumbnailEntity thumbnail) async {
    emit(state.copyWith(
      status: ArticleEditorStatus.uploadingThumbnail,
      clearError: true,
    ));

    final result = await _uploadThumbnail(
      UploadArticleThumbnailParams(
        userId: journalistId,
        thumbnail: thumbnail,
      ),
    );

    if (result is DataSuccess<String>) {
      emit(state.copyWith(
        status: ArticleEditorStatus.editing,
        article: state.article.copyWith(thumbnailUrl: result.data),
      ));
      return;
    }

    _emitFailure(result.error);
  }

  /// Saves the article keeping it private, because the journalist asked for
  /// it. The editor closes afterwards.
  Future<void> saveDraft() => _saveDraft(automatic: false);

  Future<void> _saveDraft({required bool automatic}) async {
    _autosaveTimer?.cancel();
    emit(state.copyWith(status: ArticleEditorStatus.saving, clearError: true));

    final result = state.article.isStored
        ? await _updateArticle(UpdateArticleParams(state.article))
        : await _createArticle(_createParams(ArticleStatus.draft));

    _emitSaveResult(result, automatic: automatic);
  }

  /// Saves the article and makes it readable by the audience.
  Future<void> publish() async {
    _autosaveTimer?.cancel();
    emit(state.copyWith(status: ArticleEditorStatus.saving, clearError: true));

    final result = state.article.isStored
        ? await _publishArticle(PublishArticleParams(state.article))
        : await _createArticle(_createParams(ArticleStatus.published));

    _emitSaveResult(result, automatic: false);
  }

  void _editArticle({
    String ? title,
    String ? description,
    String ? content,
  }) {
    emit(state.copyWith(
      status: ArticleEditorStatus.editing,
      article: state.article.copyWith(
        title: title,
        description: description,
        content: content,
      ),
      validationErrors: const [],
      clearError: true,
    ));
    _scheduleAutosave();
  }

  /// Debounces `saveDraft()` after an edit.
  ///
  /// Only schedules while the article is a draft that already satisfies the
  /// draft rules (title, author and owner set): editing an already published
  /// article never autosaves over the live version, and a brand new article
  /// is not saved on every keystroke before it even has a title.
  void _scheduleAutosave() {
    _autosaveTimer?.cancel();

    if (!state.article.isDraft || state.article.validateAsDraft().isNotEmpty) {
      return;
    }

    _autosaveTimer = Timer(autosaveDelay, () {
      if (!isClosed) {
        _saveDraft(automatic: true);
      }
    });
  }

  @override
  Future<void> close() {
    _autosaveTimer?.cancel();
    return super.close();
  }

  CreateArticleParams _createParams(ArticleStatus status) {
    return CreateArticleParams(
      title: state.article.title,
      description: state.article.description,
      content: state.article.content,
      author: journalistName,
      userId: journalistId,
      thumbnailUrl: state.article.thumbnailUrl,
      status: status,
    );
  }

  void _emitSaveResult(
    DataState<JournalistArticleEntity> result, {
    required bool automatic,
  }) {
    if (result is DataSuccess<JournalistArticleEntity>) {
      final stored = result.data!;

      emit(state.copyWith(
        status: automatic
            ? ArticleEditorStatus.autosaved
            : ArticleEditorStatus.saved,
        // An autosave runs while the journalist is still writing, and they may
        // have typed more while the write was in flight. Taking the whole
        // stored article back would overwrite those keystrokes with what the
        // backend received a moment ago, so only what the backend owns is
        // taken and the text on screen is left alone.
        article: automatic
            ? state.article.copyWith(
                id: stored.id,
                createdAt: stored.createdAt,
                updatedAt: stored.updatedAt,
              )
            : stored,
        validationErrors: const [],
      ));
      return;
    }

    _emitFailure(result.error);
  }

  void _emitFailure(Object ? error) {
    emit(state.copyWith(
      status: ArticleEditorStatus.failure,
      error: error,
      validationErrors: error is ArticleValidationException
          ? error.errors
          : const <ArticleValidationError>[],
    ));
  }
}
