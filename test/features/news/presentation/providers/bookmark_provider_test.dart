
import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/entities/news.dart';
import 'package:news_app/features/news/presentation/providers/bookmark_provider.dart';
import '../../../../test_utils.mocks.dart';

void main() {
  late ProviderContainer container;
  late MockGetBookmarks mockGetBookmarks;
  late MockAddBookmark mockAddBookmark;
  late MockRemoveBookmark mockRemoveBookmark;

  setUp() {
    mockGetBookmarks = MockGetBookmarks();
    mockAddBookmark = MockAddBookmark();
    mockRemoveBookmark = MockRemoveBookmark();
    container = ProviderContainer(
      overrides: [
        getBookmarksProvider.overrideWithValue(mockGetBookmarks),
        addBookmarkProvider.overrideWithValue(mockAddBookmark),
        removeBookmarkProvider.overrideWithValue(mockRemoveBookmark),
      ],
    );
  }

  tearDown() {
    container.dispose();
  }

  final tNews = News(
    id: '1',
    title: 'Test News',
    description: 'Description',
    source: 'Source',
    publishedAt: DateTime.now(),
  );

  final tBookmarks = [tNews];

  group('BookmarkNotifier', () {
    test('should load bookmarks successfully', () async {
      // Arrange
      when(mockGetBookmarks.execute()).thenAnswer((_) async => Right(tBookmarks));

      // Act
      final notifier = container.read(bookmarkProvider.notifier);
      await notifier.loadBookmarks();

      // Assert
      final state = container.read(bookmarkProvider);
      expect(state, AsyncValue.data(tBookmarks));
      verify(mockGetBookmarks.execute());
    });

    test('should handle error when loading bookmarks fails', () async {
      // Arrange
      const failure = CacheFailure('Cache error');
      when(mockGetBookmarks.execute()).thenAnswer((_) async => const Left(failure));

      // Act
      final notifier = container.read(bookmarkProvider.notifier);
      await notifier.loadBookmarks();

      // Assert
      final state = container.read(bookmarkProvider);
      expect(state, isA<AsyncError>());
      expect(state.error, 'Cache error');
      verify(mockGetBookmarks.execute());
    });

    test('should add bookmark successfully', () async {
      // Arrange
      when(mockAddBookmark.execute(any)).thenAnswer((_) async => const Right(null));
      when(mockGetBookmarks.execute()).thenAnswer((_) async => Right(tBookmarks));

      // Act
      final notifier = container.read(bookmarkProvider.notifier);
      await notifier.add(tNews);

      // Assert
      final state = container.read(bookmarkProvider);
      expect(state, AsyncValue.data(tBookmarks));
      verify(mockAddBookmark.execute(tNews));
      verify(mockGetBookmarks.execute());
    });

    test('should handle error when adding bookmark fails', () async {
      // Arrange
      const failure = CacheFailure('Cache error');
      when(mockAddBookmark.execute(any)).thenAnswer((_) async => const Left(failure));

      // Act
      final notifier = container.read(bookmarkProvider.notifier);
      await notifier.add(tNews);

      // Assert
      final state = container.read(bookmarkProvider);
      expect(state, isA<AsyncError>());
      expect(state.error, 'Cache error');
      verify(mockAddBookmark.execute(tNews));
      verifyZeroInteractions(mockGetBookmarks);
    });

    test('should remove bookmark successfully', () async {
      // Arrange
      when(mockRemoveBookmark.execute(any)).thenAnswer((_) async => const Right(null));
      when(mockGetBookmarks.execute()).thenAnswer((_) async => Right([]));

      // Act
      final notifier = container.read(bookmarkProvider.notifier);
      await notifier.remove('1');

      // Assert
      final state = container.read(bookmarkProvider);
      expect(state, AsyncValue.data([]));
      verify(mockRemoveBookmark.execute('1'));
      verify(mockGetBookmarks.execute());
    });

    test('should handle error when removing bookmark fails', () async {
      // Arrange
      const failure = CacheFailure('Cache error');
      when(mockRemoveBookmark.execute(any)).thenAnswer((_) async => const Left(failure));

      // Act
      final notifier = container.read(bookmarkProvider.notifier);
      await notifier.remove('1');

      // Assert
      final state = container.read(bookmarkProvider);
      expect(state, isA<AsyncError>());
      expect(state.error, 'Cache error');
      verify(mockRemoveBookmark.execute('1'));
      verifyZeroInteractions(mockGetBookmarks);
    });

    test('should return true when news is bookmarked', () async {
      // Arrange
      when(mockGetBookmarks.execute()).thenAnswer((_) async => Right(tBookmarks));

      // Act
      final notifier = container.read(bookmarkProvider.notifier);
      await notifier.loadBookmarks();
      final isBookmarked = notifier.isBookmarked('1');

      // Assert
      expect(isBookmarked, true);
    });

    test('should return false when news is not bookmarked', () async {
      // Arrange
      when(mockGetBookmarks.execute()).thenAnswer((_) async => Right(tBookmarks));

      // Act
      final notifier = container.read(bookmarkProvider.notifier);
      await notifier.loadBookmarks();
      final isBookmarked = notifier.isBookmarked('2');

      // Assert
      expect(isBookmarked, false);
    });
  });
}