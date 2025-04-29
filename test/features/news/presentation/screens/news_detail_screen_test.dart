import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/di/injection_container.dart';
import 'package:news_app/features/news/domain/entities/news.dart';
import 'package:news_app/features/news/domain/usecases/add_bookmark.dart';
import 'package:news_app/features/news/domain/usecases/get_bookmarks.dart';
import 'package:news_app/features/news/domain/usecases/remove_bookmark.dart';
import 'package:news_app/features/news/presentation/providers/bookmark_provider.dart';
import 'package:news_app/features/news/presentation/screens/news_detail_screen.dart';
import '../../../../test_utils.mocks.dart';

void main() {
  late MockGetBookmarks mockGetBookmarks;
  late MockAddBookmark mockAddBookmark;
  late MockRemoveBookmark mockRemoveBookmark;

  setUp(() {
    mockGetBookmarks = MockGetBookmarks();
    mockAddBookmark = MockAddBookmark();
    mockRemoveBookmark = MockRemoveBookmark();
    getIt.registerSingleton<GetBookmarks>(mockGetBookmarks);
    getIt.registerSingleton<AddBookmark>(mockAddBookmark);
    getIt.registerSingleton<RemoveBookmark>(mockRemoveBookmark);
  });

  tearDown(() {
    getIt.reset();
  });

  final tNews = News(
    id: '1',
    title: 'Test News',
    description: 'Description',
    source: 'Source',
    imageUrl: 'http://example.com/image.jpg',
    content: 'Full content',
    publishedAt: DateTime.now(),
  );

  testWidgets('NewsDetailScreen displays news details', (WidgetTester tester) async {
    // Arrange
    when(mockGetBookmarks.execute()).thenAnswer((_) async => Right([]));

    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: NewsDetailScreen(news: tNews),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Test News'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Source'), findsOneWidget);
    expect(find.text('Full content'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
  });

  testWidgets('NewsDetailScreen toggles bookmark', (WidgetTester tester) async {
    // Arrange
    when(mockGetBookmarks.execute()).thenAnswer((_) async => Right([]));
    when(mockAddBookmark.execute(any)).thenAnswer((_) async => Right(null));
    when(mockGetBookmarks.execute()).thenAnswer((_) async => Right([tNews]));

    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: NewsDetailScreen(news: tNews),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap bookmark button
    await tester.tap(find.byIcon(Icons.bookmark_border));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byIcon(Icons.bookmark), findsOneWidget); // NFR 4: UI updates
    verify(mockAddBookmark.execute(tNews));
  });
}