import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_failures.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';

import '../../../../helpers/article_fixtures.dart';

void main() {
  group('extension', () {
    test('is read from the file name and lower cased', () {
      expect(thumbnail(fileName: 'Cover.PNG').extension, 'png');
    });

    test('is empty when the file name has no extension', () {
      expect(thumbnail(fileName: 'cover').extension, '');
    });
  });

  group('validate', () {
    test('accepts a small jpg', () {
      expect(thumbnail().validate(), isEmpty);
      expect(thumbnail().isValid, isTrue);
    });

    test('rejects an empty file', () {
      expect(
        thumbnail(sizeInBytes: 0).validate(),
        contains(ThumbnailValidationError.emptyFile),
      );
    });

    test('rejects a file bigger than the storage rules allow', () {
      final tooBig = thumbnail(
        sizeInBytes: ArticleThumbnailEntity.maxSizeInBytes + 1,
      );

      expect(
        tooBig.validate(),
        contains(ThumbnailValidationError.fileTooLarge),
      );
    });

    test('rejects a format the app does not support', () {
      expect(
        thumbnail(fileName: 'cover.gif').validate(),
        contains(ThumbnailValidationError.unsupportedFormat),
      );
    });
  });
}
