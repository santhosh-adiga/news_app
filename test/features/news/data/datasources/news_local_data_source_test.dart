import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app/features/news/data/models/news_model.dart';

class MockBox<T> extends Mock implements Box<T> {}

void main() {
  late NewsLocalDataSourceImpl dataSource;
  late MockBox<List<NewsModel>> mockNewsBox;
  late MockBox<NewsModel> mockBookmarkBox;

  setUp(() async {
    mockNewsBox = MockBox<List<NewsModel>>();
    mockBookmarkBox = MockBox<NewsModel>();
    // Mock Hive box behavior with specific box names
    when(Hive.box<List<NewsModel>>('newsBox')).thenReturn(mockNewsBox);
    when(Hive.box<NewsModel>('bookmarkBox')).thenReturn(mockBookmarkBox);
    when(Hive.isBoxOpen('newsBox')).thenReturn(true);
    when(Hive.isBoxOpen('bookmarkBox')).thenReturn(true);
    dataSource = NewsLocalDataSourceImpl();
  });

  group('NewsLocalDataSourceImpl', () {
    final tNewsList = [
      NewsModel(
        id: '1',
        title: 'Test News',
        description: 'Description',
        source: 'Source',
        publishedAt: DateTime.now(),
      ),
    ];

    const tCacheKey = 'general_';

    test('should return cached news when available', () async {
      // Arrange
      when(mockNewsBox.get(tCacheKey, defaultValue: anyNamed('defaultValue')))
          .thenReturn(tNewsList);

      // Act
      final result = await dataSource.getCachedNews(tCacheKey);

      // Assert
      expect(result, tNewsList);
      verify(mockNewsBox.get(tCacheKey, defaultValue: []));
    });

    test('should throw CacheFailure when getting cached news fails', () async {
      // Arrange
      when(mockNewsBox.get(tCacheKey, defaultValue: anyNamed('defaultValue')))
          .thenThrow(Exception('Cache error'));

      // Act & Assert
      expect(() => dataSource.getCachedNews(tCacheKey),
          throwsA(isA<CacheFailure>()));
    });

    test('should cache news successfully', () async {
      // Arrange
      when(mockNewsBox.put(tCacheKey, tNewsList)).thenAnswer((_) async => null);

      // Act
      await dataSource.cacheNews(tNewsList, tCacheKey);

      // Assert
      verify(mockNewsBox.put(tCacheKey, tNewsList));
    });

    test('should throw CacheFailure when caching news fails', () async {
      // Arrange
      when(mockNewsBox.put(tCacheKey, tNewsList))
          .thenThrow(Exception('Cache error'));

      // Act & Assert
      expect(() => dataSource.cacheNews(tNewsList, tCacheKey),
          throwsA(isA<CacheFailure>()));
    });

    test('should return bookmarks when available', () async {
      // Arrange
      when(mockBookmarkBox.values).thenReturn(tNewsList);

      // Act
      final result = await dataSource.getBookmarks();

      // Assert
      expect(result, tNewsList);
    });

    test('should throw CacheFailure when getting bookmarks fails', () async {
      // Arrange
      when(mockBookmarkBox.values).thenThrow(Exception('Cache error'));

      // Act & Assert
      expect(() => dataSource.getBookmarks(), throwsA(isA<CacheFailure>()));
    });

    test('should add bookmark successfully', () async {
      // Arrange
      when(mockBookmarkBox.put(tNewsList.first.id, tNewsList.first))
          .thenAnswer((_) async => null);

      // Act
      await dataSource.addBookmark(tNewsList.first);

      // Assert
      verify(mockBookmarkBox.put(tNewsList.first.id, tNewsList.first));
    });

    test('should throw CacheFailure when adding bookmark fails', () async {
      // Arrange
      when(mockBookmarkBox.put(tNewsList.first.id, tNewsList.first))
          .thenThrow(Exception('Cache error'));

      // Act & Assert
      expect(() => dataSource.addBookmark(tNewsList.first),
          throwsA(isA<CacheFailure>()));
    });

    test('should remove bookmark successfully', () async {
      // Arrange
      when(mockBookmarkBox.delete('1')).thenAnswer((_) async => null);

      // Act
      await dataSource.removeBookmark('1');

      // Assert
      verify(mockBookmarkBox.delete('1'));
    });

    test('should throw CacheFailure when removing bookmark fails', () async {
      // Arrange
      when(mockBookmarkBox.delete('1')).thenThrow(Exception('Cache error'));

      // Act & Assert
      expect(
          () => dataSource.removeBookmark('1'), throwsA(isA<CacheFailure>()));
    });
  });
}
