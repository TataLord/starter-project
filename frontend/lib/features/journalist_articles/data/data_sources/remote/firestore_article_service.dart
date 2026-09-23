import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';

import '../../../domain/entities/article_status.dart';
import '../../models/journalist_article_model.dart';

/// The only class in the app that talks to the `articles` collection.
///
/// It throws whatever Firestore throws; turning that into the domain's
/// failures is the repository's job.
class FirestoreArticleService {
  final FirebaseFirestore _firestore;

  const FirestoreArticleService(this._firestore);

  CollectionReference<Map<String, dynamic>> get _articles =>
      _firestore.collection(kArticlesCollection);

  /// Articles owned by [userId], most recently edited first.
  ///
  /// [searchQuery] is applied in memory, on the author's own articles only.
  /// Firestore has no substring search, and the alternatives (a search
  /// service, or denormalised keyword arrays) are not worth it for a list one
  /// person owns.
  Future<List<JournalistArticleModel>> getUserArticles({
    required String userId,
    ArticleStatus ? status,
    String ? searchQuery,
  }) async {
    Query<Map<String, dynamic>> query =
        _articles.where('userId', isEqualTo: userId);

    if (status != null) {
      query = query.where('status', isEqualTo: status.value);
    }

    final snapshot = await query.orderBy('updatedAt', descending: true).get();

    final articles = snapshot.docs
        .map(JournalistArticleModel.fromSnapshot)
        .toList();

    return _applySearchQuery(articles, searchQuery);
  }

  Future<JournalistArticleModel ?> getArticleById(String articleId) async {
    final snapshot = await _articles.doc(articleId).get();

    if (!snapshot.exists) {
      return null;
    }

    return JournalistArticleModel.fromSnapshot(snapshot);
  }

  /// Published articles, most recently published first.
  ///
  /// The query always filters by `status`, which is what lets an unauthenticated
  /// reader run it at all: `firestore.rules` rejects a `list` whose filters do
  /// not guarantee every result is readable.
  Future<List<JournalistArticleModel>> getPublishedArticles({
    int limit = 20,
    String ? authorId,
    String ? excludeArticleId,
    String ? startAfterArticleId,
  }) async {
    Query<Map<String, dynamic>> query = _articles.where(
      'status',
      isEqualTo: ArticleStatus.published.value,
    );

    if (authorId != null) {
      query = query.where('userId', isEqualTo: authorId);
    }

    query = query.orderBy('publishedAt', descending: true);

    if (startAfterArticleId != null) {
      final cursor = await _articles.doc(startAfterArticleId).get();
      if (cursor.exists) {
        query = query.startAfterDocument(cursor);
      }
    }

    // Firestore cannot express "everything except this document" alongside the
    // other filters without extra index constraints, so one extra row is
    // fetched and the excluded one is dropped here.
    final snapshot =
        await query.limit(excludeArticleId == null ? limit : limit + 1).get();

    return snapshot.docs
        .map(JournalistArticleModel.fromSnapshot)
        .where((article) => article.id != excludeArticleId)
        .take(limit)
        .toList();
  }

  /// Writes a new document and returns it as stored, so the caller gets the
  /// id Firestore generated.
  Future<JournalistArticleModel> createArticle(
    JournalistArticleModel article,
  ) async {
    final reference = await _articles.add(article.toFirestore());
    final snapshot = await reference.get();

    return JournalistArticleModel.fromSnapshot(snapshot);
  }

  Future<JournalistArticleModel> updateArticle(
    JournalistArticleModel article,
  ) async {
    final reference = _articles.doc(article.id);

    await reference.update(article.toFirestoreUpdate());

    final snapshot = await reference.get();

    return JournalistArticleModel.fromSnapshot(snapshot);
  }

  Future<void> deleteArticle(String articleId) {
    return _articles.doc(articleId).delete();
  }

  /// Raises the article's view count by one.
  ///
  /// [FieldValue.increment] keeps this correct when several readers open the
  /// same article at once, and it is the only shape `firestore.rules` accepts
  /// from somebody who is not the author.
  Future<void> incrementViewCount(String articleId) {
    return _articles.doc(articleId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  List<JournalistArticleModel> _applySearchQuery(
    List<JournalistArticleModel> articles,
    String ? searchQuery,
  ) {
    if (searchQuery == null || searchQuery.trim().isEmpty) {
      return articles;
    }

    final query = searchQuery.trim().toLowerCase();

    return articles
        .where((article) =>
            article.title.toLowerCase().contains(query) ||
            article.description.toLowerCase().contains(query) ||
            article.content.toLowerCase().contains(query))
        .toList();
  }
}
