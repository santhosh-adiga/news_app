import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/di/injection_container.dart';
import 'package:news_app/features/news/domain/entities/news.dart';
import 'package:news_app/features/news/domain/usecases/add_bookmark.dart';
import 'package:news_app/features/news/domain/usecases/get_bookmarks.dart';
import 'package:news_app/features/news/domain/usecases/get_news.dart';
import 'package:news_app/features/news/domain/usecases/remove_bookmark.dart';
import 'package:news_app/features/news/presentation/screens/news_detail_screen.dart';
import 'package:news_app/features/news/presentation/widgets/tabbed_news_view.dart';
import '../../../../test_utils.mocks.dart';

void main() {
  late MockGetNews mockGetNews;
  late MockGetBookmarks mockGetBookmarks;
  late MockAddBookmark mockAddBookmark;
  late MockRemoveBookmark mockRemoveBookmark;

  setUp(() {
    mockGetNews = MockGetNews();
    mockGetBookmarks = MockGetBookmarks();
    mockAddBookmark = MockAddBookmark();
    mockRemoveBookmark = MockRemoveBookmark();
    getIt.registerSingleton<GetNews>(mockGetNews);
    getIt.registerSingleton<GetBookmarks>(mockGetBookmarks);
    getIt.registerSingleton<AddBookmark>(mockAddBookmark);
    getIt.registerSingleton<RemoveBookmark>(mockRemoveBookmark);
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

  testWidgets('TabbedNewsView displays tabs and news', (WidgetTester tester) async {
    // Arrange
    when(mockGetNews.execute(category: anyNamed('category'), query: anyNamed('query')))
        .thenAnswer((_) async => Right(tNewsList));
    when(mockGetBookmarks.execute()).thenAnswer((_) async => Right([]));

    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: TabbedNewsView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Sports'), findsOneWidget);
    expect(find.text('Tech'), findsOneWidget);
    expect(find.text('Bookmarks'), findsOneWidget);
    expect(find.text('Test News'), findsOneWidget);
  });

  testWidgets('TabbedNewsView switches tabs', (WidgetTester tester) async {
    // Arrange
    when(mockGetNews.execute(category: anyNamed('category'), query: anyNamed('query')))
        .thenAnswer((_) async => Right(tNewsList));
    when(mockGetBookmarks.execute()).thenAnswer((_) async => Right([]));

    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: TabbedNewsView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to Sports tab
    await tester.tap(find.text('Sports'));
    await tester.pumpAndSettle();

    // Assert
    verify(mockGetNews.execute(category: 'sports', query: null));
  });

  testWidgets('TabbedNewsView performs search', (WidgetTester tester) async {
    // Arrange
    when(mockGetNews.execute(category: anyNamed('category'), query: anyNamed('query')))
        .thenAnswer((_) async => Right(tNewsList));
    when(mockGetBookmarks.execute()).thenAnswer((_) async => Right([]));

    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: TabbedNewsView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Enter search query
    await tester.enterText(find.byType(TextField), 'tech');
    await tester.pumpAndSettle();

    // Assert
    verify(mockGetNews.execute(category: null, query: 'tech')); // NFR 4: UI updates
  });

  testWidgets('TabbedNewsView selects category', (WidgetTester tester) async {
    // Arrange
    when(mockGetNews.execute(category: anyNamed('category'), query: anyNamed('query')))
        .thenAnswer((_) async => Right(tNewsList));
    when(mockGetBookmarks.execute()).thenAnswer((_) async => Right([]));

    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: TabbedNewsView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Select category
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Business').last);
    await tester.pumpAndSettle();

    // Assert
    verify(mockGetNews.execute(category: 'business', query: null)); // NFR 4: UI updates
  });

  testWidgets('TabbedNewsView navigates to NewsDetailScreen', (WidgetTester tester) async {
    // Arrange
    when(mockGetNews.execute(category: anyNamed('category'), query: anyNamed('query')))
        .thenAnswer((_) async => Right(tNewsList));
    when(mockGetBookmarks.execute()).thenAnswer((_) async => Right([]));

    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: TabbedNewsView(),
          routes: {
            '/news_detail': (context) => NewsDetailScreen(news: tNewsList.first),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap news tile
    await tester.tap(find.text('Test News'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(NewsDetailScreen), findsOneWidget);
  });
}