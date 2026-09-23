import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/create_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_article_by_id.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/update_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/upload_article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_editor/article_editor_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/screens/article_editor/article_editor_screen.dart';

import '../../../../../helpers/fake_article_thumbnail_repository.dart';
import '../../../../../helpers/fake_journalist_article_repository.dart';

void main() {
  late FakeJournalistArticleRepository articleRepository;
  late FakeArticleThumbnailRepository thumbnailRepository;
  late ArticleEditorCubit cubit;

  setUp(() {
    articleRepository = FakeJournalistArticleRepository();
    thumbnailRepository = FakeArticleThumbnailRepository();
    cubit = ArticleEditorCubit(
      GetArticleByIdUseCase(articleRepository),
      CreateArticleUseCase(articleRepository),
      UpdateArticleUseCase(articleRepository),
      PublishArticleUseCase(articleRepository),
      UploadArticleThumbnailUseCase(thumbnailRepository),
      journalistId: 'journalist-1',
      journalistName: 'Alex Rivera',
    )..startNewArticle();
  });

  tearDown(() => cubit.close());

  Future<void> pumpScreen(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ArticleEditorCubit>.value(
          value: cubit,
          child: const ArticleEditorScreen(),
        ),
      ),
    );
  }

  testWidgets('offers an empty form for a new article', (tester) async {
    await pumpScreen(tester);

    expect(find.text('New article'), findsOneWidget);
    expect(find.text('No cover image attached'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Publish'), findsOneWidget);
  });

  testWidgets('keeps what the journalist types in the editor state',
      (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).first, 'Working title');

    expect(cubit.state.article.title, 'Working title');

    // Every edit schedules an autosave (see ArticleEditorCubit._scheduleAutosave);
    // let it fire so no Timer is left pending once the test tears down.
    await tester.pump(cubit.autosaveDelay);
  });

  testWidgets('stays open when the article autosaves', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).first, 'Working title');
    await tester.pump(cubit.autosaveDelay);
    await tester.pump();

    // The editor must survive an autosave: popping here is what used to throw
    // the journalist out of the article every couple of seconds.
    expect(find.byType(ArticleEditorScreen), findsOneWidget);
    expect(find.text('Draft saved'), findsOneWidget);
    expect(articleRepository.createCallCount, 1);
  });

  testWidgets('explains why an empty article cannot be published',
      (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Publish'));
    await tester.pumpAndSettle();

    // The message is reported in the snack bar and inline under the form.
    expect(find.textContaining('The article needs a title.'), findsWidgets);
    expect(articleRepository.createCallCount, 0);
  });

  testWidgets('attaches a cover image through the upload use case',
      (tester) async {
    await pumpScreen(tester);

    // Tapped by label: OutlinedButton.icon builds a private subclass in some
    // Flutter versions, which find.byType (exact type) would miss.
    await tester.tap(find.text('Attach cover'));
    await tester.pump();
    await tester.pump();

    expect(thumbnailRepository.uploadCallCount, 1);
    expect(cubit.state.article.thumbnailUrl, isNotEmpty);
  });
}
