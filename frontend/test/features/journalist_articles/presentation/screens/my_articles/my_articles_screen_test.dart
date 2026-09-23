import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/delete_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_my_articles.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/screens/my_articles/my_articles_screen.dart';

import '../../../../../helpers/article_fixtures.dart';
import '../../../../../helpers/fake_journalist_article_repository.dart';

void main() {
  late FakeJournalistArticleRepository repository;
  late MyArticlesCubit cubit;

  setUp(() {
    repository = FakeJournalistArticleRepository();
    cubit = MyArticlesCubit(
      GetMyArticlesUseCase(repository),
      PublishArticleUseCase(repository),
      DeleteArticleUseCase(repository),
      journalistId: 'journalist-1',
    );
  });

  tearDown(() => cubit.close());

  Future<void> pumpScreen(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<MyArticlesCubit>.value(
          value: cubit,
          child: const MyArticlesScreen(),
        ),
      ),
    );
  }

  testWidgets('lists the articles of the journalist', (tester) async {
    repository.userArticlesResult = DataSuccess([publishableArticle()]);

    await pumpScreen(tester);
    await cubit.loadArticles();
    await tester.pump();

    expect(find.text(publishableArticle().title), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
  });

  testWidgets('invites the journalist to write when there is nothing yet',
      (tester) async {
    await pumpScreen(tester);
    await cubit.loadArticles();
    await tester.pump();

    expect(find.text('No articles yet. Write one!'), findsOneWidget);
  });

  testWidgets('filters the list by status', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Drafts'));
    await tester.pump();
    await tester.pump();

    expect(repository.lastStatusFilter, isNotNull);
  });
}
