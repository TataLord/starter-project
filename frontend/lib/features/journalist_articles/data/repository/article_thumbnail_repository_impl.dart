import 'package:firebase_core/firebase_core.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../domain/entities/article_thumbnail.dart';
import '../../domain/repository/article_thumbnail_repository.dart';
import '../data_sources/remote/article_storage_service.dart';

/// Cloud Storage implementation of [ArticleThumbnailRepository].
class ArticleThumbnailRepositoryImpl implements ArticleThumbnailRepository {
  final ArticleStorageService _storageService;

  const ArticleThumbnailRepositoryImpl(this._storageService);

  @override
  Future<DataState<String>> uploadThumbnail({
    required String userId,
    required ArticleThumbnailEntity thumbnail,
  }) async {
    try {
      final downloadUrl = await _storageService.uploadThumbnail(
        userId: userId,
        thumbnail: thumbnail,
      );

      return DataSuccess(downloadUrl);
    } on FirebaseException catch (error) {
      return DataFailed(error);
    } catch (error) {
      // An error that escapes here would hang the editor's upload spinner
      // instead of reporting anything.
      return DataFailed(error);
    }
  }
}
