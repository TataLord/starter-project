import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';

import '../../../domain/entities/article_thumbnail.dart';

/// The only class in the app that talks to Cloud Storage.
class ArticleStorageService {
  final FirebaseStorage _storage;

  const ArticleStorageService(this._storage);

  /// Uploads [thumbnail] into the folder owned by [userId] and returns its
  /// download URL.
  ///
  /// The path matches the one `backend/storage.rules` allows a user to write
  /// to (`media/articles/{userId}/...`); the file name is made unique so two
  /// covers picked from the same camera roll cannot overwrite each other.
  Future<String> uploadThumbnail({
    required String userId,
    required ArticleThumbnailEntity thumbnail,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}'
        '.${thumbnail.extension}';

    final reference =
        _storage.ref().child('$kArticleMediaFolder/$userId/$fileName');

    await reference.putData(
      thumbnail.bytes,
      SettableMetadata(contentType: _contentTypeFor(thumbnail.extension)),
    );

    return reference.getDownloadURL();
  }

  /// Cloud Storage guesses `application/octet-stream` for raw bytes, which
  /// would stop the image from rendering in a browser.
  String _contentTypeFor(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
