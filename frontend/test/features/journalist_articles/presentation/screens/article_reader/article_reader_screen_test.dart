import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/screens/article_reader/article_reader_screen.dart';

import '../../../../../helpers/article_fixtures.dart';

void main() {
  testWidgets('shows the article content', (tester) async {
    final article = publishableArticle();

    await tester.pumpWidget(
      MaterialApp(home: ArticleReaderScreen(article: article)),
    );

    expect(find.text(article.title), findsOneWidget);
    expect(find.text('By ${article.author}'), findsOneWidget);
    expect(find.text(article.content), findsOneWidget);
  });

  testWidgets('navigates to the author feed with the right arguments',
      (tester) async {
    final article = publishableArticle();
    Map<String, dynamic> ? capturedArgs;

    await tester.pumpWidget(
      MaterialApp(
        home: ArticleReaderScreen(article: article),
        onGenerateRoute: (settings) {
          if (settings.name == '/ArticleFeed') {
            capturedArgs = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Text(capturedArgs !['title'] as String),
              ),
            );
          }
          return null;
        },
      ),
    );

    await tester.tap(
      find.widgetWithText(OutlinedButton, 'More from ${article.author}'),
    );
    await tester.pumpAndSettle();

    expect(capturedArgs !['authorId'], article.userId);
    expect(capturedArgs !['excludeArticleId'], article.id);
    expect(capturedArgs !['title'], 'More from ${article.author}');
  });
}
