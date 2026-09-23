import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/journalist_article_repository.dart';

/// Hand written test double for [JournalistArticleRepository].
///
/// It records what the use cases asked for and returns whatever the test
/// configured, which is everything needed to assert business rules without
/// pulling a mocking framework into the project.
class FakeJournalistArticleRepository implements JournalistArticleRepository {
  DataState<List<JournalistArticleEntity>> userArticlesResult =
      const DataSuccess(<JournalistArticleEntity>[]);
  DataState<JournalistArticleEntity> ? articleByIdResult;
  DataState<JournalistArticleEntity> ? createResult;
  DataState<JournalistArticleEntity> ? updateResult;
  DataState<void> deleteResult = const DataSuccess(null);
  DataState<List<JournalistArticleEntity>> publishedArticlesResult =
      const DataSuccess(<JournalistArticleEntity>[]);
  DataState<void> incrementViewCountResult = const DataSuccess(null);

  int createCallCount = 0;
  int updateCallCount = 0;
  int deleteCallCount = 0;
  int incrementViewCountCallCount = 0;

  JournalistArticleEntity ? lastCreatedArticle;
  JournalistArticleEntity ? lastUpdatedArticle;
  String ? lastRequestedArticleId;
  String ? lastDeletedArticleId;
  String ? lastViewedArticleId;
  String ? lastUserId;
  ArticleStatus ? lastStatusFilter;
  String ? lastSearchQuery;
  int ? lastPublishedArticlesLimit;
  String ? lastPublishedArticlesAuthorId;
  String ? lastPublishedArticlesExcludeArticleId;
  String ? lastPublishedArticlesStartAfterArticleId;

  @override
  Future<DataState<List<JournalistArticleEntity>>> getUserArticles({
    required String userId,
    ArticleStatus ? status,
    String ? searchQuery,
  }) async {
    lastUserId = userId;
    lastStatusFilter = status;
    lastSearchQuery = searchQuery;
    return userArticlesResult;
  }

  @override
  Future<DataState<JournalistArticleEntity>> getArticleById(
    String articleId,
  ) async {
    lastRequestedArticleId = articleId;
    return articleByIdResult ??
        const DataSuccess(JournalistArticleEntity(id: 'unset'));
  }

  @override
  Future<DataState<JournalistArticleEntity>> createArticle(
    JournalistArticleEntity article,
  ) async {
    createCallCount++;
    lastCreatedArticle = article;
    return createResult ?? DataSuccess(article.copyWith(id: 'created-id'));
  }

  @override
  Future<DataState<JournalistArticleEntity>> updateArticle(
    JournalistArticleEntity article,
  ) async {
    updateCallCount++;
    lastUpdatedArticle = article;
    return updateResult ?? DataSuccess(article);
  }

  @override
  Future<DataState<void>> deleteArticle(String articleId) async {
    deleteCallCount++;
    lastDeletedArticleId = articleId;
    return deleteResult;
  }

  @override
  Future<DataState<List<JournalistArticleEntity>>> getPublishedArticles({
    int limit = 20,
    String ? authorId,
    String ? excludeArticleId,
    String ? startAfterArticleId,
  }) async {
    lastPublishedArticlesLimit = limit;
    lastPublishedArticlesAuthorId = authorId;
    lastPublishedArticlesExcludeArticleId = excludeArticleId;
    lastPublishedArticlesStartAfterArticleId = startAfterArticleId;
    return publishedArticlesResult;
  }

  @override
  Future<DataState<void>> incrementViewCount(String articleId) async {
    incrementViewCountCallCount++;
    lastViewedArticleId = articleId;
    return incrementViewCountResult;
  }
}
