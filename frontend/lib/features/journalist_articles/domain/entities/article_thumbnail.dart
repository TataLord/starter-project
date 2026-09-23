import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import 'article_failures.dart';

/// Image a journalist attaches to an article before uploading it.
///
/// The limits mirror the ones enforced by `backend/storage.rules`, so an
/// invalid thumbnail is rejected by the business layer instead of travelling
/// to Cloud Storage just to be rejected there.
class ArticleThumbnailEntity extends Equatable {
  static const int maxSizeInBytes = 5 * 1024 * 1024;
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  final String fileName;
  final Uint8List bytes;

  const ArticleThumbnailEntity({
    required this.fileName,
    required this.bytes,
  });

  /// Lower cased extension of [fileName], without the dot.
  String get extension {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  int get sizeInBytes => bytes.lengthInBytes;

  bool get isValid => validate().isEmpty;

  List<ThumbnailValidationError> validate() {
    final errors = <ThumbnailValidationError>[];

    if (sizeInBytes == 0) {
      errors.add(ThumbnailValidationError.emptyFile);
    }
    if (sizeInBytes > maxSizeInBytes) {
      errors.add(ThumbnailValidationError.fileTooLarge);
    }
    if (!allowedExtensions.contains(extension)) {
      errors.add(ThumbnailValidationError.unsupportedFormat);
    }

    return errors;
  }

  @override
  List<Object ?> get props => [fileName, bytes];
}
