import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/di/injection_container.dart';
import 'package:news_app/features/news/domain/entities/news.dart';
import 'package:news_app/features/news/domain/usecases/get_news.dart';
import 'package:news_app/features/news/presentation/screens/news_list_screen.dart';
import '../../../../test_utils.mocks.dart';

void main() {
  late MockGetNews mockGetNews;

  setUp(() {
    mockGetNews = MockGetNews();
    getIt.registerSingleton<GetNews>(mockGetNews);
  });

  tearDown(() {
    getIt.reset();
  });

  final tNewsList = [
    News(
      id: '1',
      title: 'Test News',
      description: 'Description',
      source: 'Source',
      publishedAt: DateTime.now(),
    ),
  ];

  testWidgets('NewsListScreen displays TabbedNewsView with tabs', (WidgetTester tester) async {
    // Arrange
    when(mockGetNews.execute(category: anyNamed('category'), query: anyNamed('query')))
        .thenAnswer((_) async => Right(tNewsList));

    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: NewsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Sports'), findsOneWidget);
    expect(find.text('Tech'), findsOneWidget);
    expect(find.text('Bookmarks'), findsOneWidget);
    expect(find.text('Test News'), findsOneWidget); // NFR 4: UI renders data
  });

  testWidgets('NewsListScreen shows loading state', (WidgetTester tester) async {
    // Arrange
    when(mockGetNews.execute(category: anyNamed('category'), query: anyNamed('query')))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return Right(tNewsList);
    });

    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: NewsListScreen(),
        ),
      ),
    );
    await tester.pump(); // Partial pump to show loading

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget); // NFR 5: Unified loading
  });

  testWidgets('NewsListScreen shows error state', (WidgetTester tester) async {
    // Arrange
    when(mockGetNews.execute(category: anyNamed('category'), query: anyNamed('query')))
        .thenAnswer((_) async => Left(ServerFailure('Server error')));

    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: NewsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Error: Server error'), findsOneWidget); // NFR 5: Unified error
  });
}