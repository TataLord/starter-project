import 'package:equatable/equatable.dart';

/// Input of `GetPublishedArticlesUseCase`.
///
/// With [authorId] left null this is the general feed of published articles;
/// set, it becomes "more articles from this journalist". [excludeArticleId]
/// leaves out the article a reader may already be looking at.
/// [startAfterArticleId] is the id of the last article of the previous page,
/// so the feed can be paged with a cursor instead of an offset.
class GetPublishedArticlesParams extends Equatable {
  final int limit;
  final String ? authorId;
  final String ? excludeArticleId;
  final String ? startAfterArticleId;

  const GetPublishedArticlesParams({
    this.limit = 20,
    this.authorId,
    this.excludeArticleId,
    this.startAfterArticleId,
  });

  @override
  List<Object ?> get props => [
        limit,
        authorId,
        excludeArticleId,
        startAfterArticleId,
      ];
}
