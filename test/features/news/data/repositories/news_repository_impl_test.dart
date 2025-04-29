
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/core/network/network_info.dart';
import 'package:news_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_app/features/news/data/models/news_model.dart';
import 'package:news_app/features/news/data/repositories/news_repository_impl.dart';
import '../../../../test_utils.mocks.dart';

void main() {
  late NewsRepositoryImpl repository;
  late MockNewsRemoteDataSource mockRemoteDataSource;
  late MockNewsLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockNewsRemoteDataSource();
    mockLocalDataSource = MockNewsLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NewsRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  final tNewsList = [
    NewsModel(
      id: '1',
      title: 'Test News',
      description: 'Description',
      source: 'Source',
      publishedAt: DateTime.now(),
    ),
  ];

  group('NewsRepositoryImpl', () {
    group('getNews', () {
      test('should return cached news within 10 minutes', () async {
        // Arrange
        final cacheKey = repository._getCacheKey(category: null, query: null);
        repository._cachedNews[cacheKey] = tNewsList;
        repository._lastFetched[cacheKey] = DateTime.now().subtract(const Duration(minutes: 5));

        // Act
        final result = await repository.getNews();

        // Assert
        expect(result, Right(tNewsList));
        verifyZeroInteractions(mockRemoteDataSource);
        verifyZeroInteractions(mockLocalDataSource);
        verifyZeroInteractions(mockNetworkInfo);
      });

      test('should fetch remote news when online and cache is stale', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.getNews(category: anyNamed('category'), query: anyNamed('query')))
            .thenAnswer((_) async => tNewsList);
        when(mockLocalDataSource.cacheNews(any, any)).thenAnswer((_) async {});

        // Act
        final result = await repository.getNews(category: 'sports', query: 'test');

        // Assert
        expect(result, Right(tNewsList));
        verify(mockNetworkInfo.isConnected);
        verify(mockRemoteDataSource.getNews(category: 'sports', query: 'test'));
        verify(mockLocalDataSource.cacheNews(tNewsList, 'sports_test'));
        verifyNoMoreInteractions(mockRemoteDataSource);
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('should return cached news when offline and cache is available', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(mockLocalDataSource.getCachedNews(any)).thenAnswer((_) async => tNewsList);

        // Act
        final result = await repository.getNews();

        // Assert
        expect(result, Right(tNewsList));
        verify(mockNetworkInfo.isConnected);
        verify(mockLocalDataSource.getCachedNews('general_'));
        verifyNoMoreInteractions(mockLocalDataSource);
        verifyZeroInteractions(mockRemoteDataSource);
      });

      test('should return NetworkFailure when offline and no cache', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(mockLocalDataSource.getCachedNews(any)).thenAnswer((_) async => []);

        // Act
        final result = await repository.getNews();

        // Assert
        expect(result, const Left(NetworkFailure('No network and no cached data')));
        verify(mockNetworkInfo.isConnected);
        verify(mockLocalDataSource.getCachedNews('general_'));
        verifyNoMoreInteractions(mockLocalDataSource);
        verifyZeroInteractions(mockRemoteDataSource);
      });

      test('should return ServerFailure when remote fetch fails', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.getNews(category: anyNamed('category'), query: anyNamed('query')))
            .thenThrow(const ServerFailure('Server error'));

        // Act
        final result = await repository.getNews();

        // Assert
        expect(result, const Left(ServerFailure('Server error')));
        verify(mockNetworkInfo.isConnected);
        verify(mockRemoteDataSource.getNews(category: null, query: null));
        verifyNoMoreInteractions(mockRemoteDataSource);
        verifyZeroInteractions(mockLocalDataSource);
      });
    });

    group('getBookmarks', () {
      test('should return bookmarks from local data source', () async {
        // Arrange
        when(mockLocalDataSource.getBookmarks()).thenAnswer((_) async => tNewsList);

        // Act
        final result = await repository.getBookmarks();

        // Assert
        expect(result, Right(tNewsList));
        verify(mockLocalDataSource.getBookmarks());
        verifyNoMoreInteractions(mockLocalDataSource);
        verifyZeroInteractions(mockRemoteDataSource);
      });

      test('should return CacheFailure when local data source fails', () async {
        // Arrange
        when(mockLocalDataSource.getBookmarks())
            .thenThrow(const CacheFailure('Cache error'));

        // Act
        final result = await repository.getBookmarks();

        // Assert
        expect(result, const Left(CacheFailure('Cache error')));
        verify(mockLocalDataSource.getBookmarks());
        verifyNoMoreInteractions(mockLocalDataSource);
      });
    });

    group('addBookmark', () {
      test('should add bookmark successfully', () async {
        // Arrange
        when(mockLocalDataSource.addBookmark(any)).thenAnswer((_) async {});

        // Act
        final result = await repository.addBookmark(tNewsList.first);

        // Assert
        expect(result, const Right(null));
        verify(mockLocalDataSource.addBookmark(any));
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('should return CacheFailure when adding bookmark fails', () async {
        // Arrange
        when(mockLocalDataSource.addBookmark(any))
            .thenThrow(const CacheFailure('Cache error'));

        // Act
        final result = await repository.addBookmark(tNewsList.first);

        // Assert
        expect(result, const Left(CacheFailure('Cache error')));
        verify(mockLocalDataSource.addBookmark(any));
        verifyNoMoreInteractions(mockLocalDataSource);
      });
    });

    group('removeBookmark', () {
      test('should remove bookmark successfully', () async {
        // Arrange
        when(mockLocalDataSource.removeBookmark(any)).thenAnswer((_) async {});

        // Act
        final result = await repository.removeBookmark('1');

        // Assert
        expect(result, const Right(null));
        verify(mockLocalDataSource.removeBookmark('1'));
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('should return CacheFailure when removing bookmark fails', () async {
        // Arrange
        when(mockLocalDataSource.removeBookmark(any))
            .thenThrow(const CacheFailure('Cache error'));

        // Act
        final result = await repository.removeBookmark('1');

        // Assert
        expect(result, const Left(CacheFailure('Cache error')));
        verify(mockLocalDataSource.removeBookmark('1'));
        verifyNoMoreInteractions(mockLocalDataSource);
      });
    });
  });
}