import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/entities/news.dart';
import 'package:news_app/features/news/presentation/providers/news_provider.dart';

import '../../../../test_utils.mocks.dart';

void main() {
  late ProviderContainer container;
  late MockGetNews mockGetNews;
  late MockDio mockDio;

  setUp(() {
    mockGetNews = MockGetNews();
    mockDio = MockDio();
    container = ProviderContainer(
      overrides: [
        getNewsProvider.overrideWithValue(mockGetNews),
      ],
    );
  });

  tearDown(() {
    container.dispose();
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

  group('NewsNotifier', () {
    test('should load news successfully', () async {
      // Arrange
      when(mockGetNews.execute(
              category: anyNamed('category'), query: anyNamed('query')))
          .thenAnswer((_) async => Right(tNewsList));

      // Act
      final notifier = container.read(newsProvider.notifier);
      await notifier.loadNews();

      // Assert
      final state = container.read(newsProvider);
      expect(state, AsyncValue.data(tNewsList));
      verify(mockGetNews.execute(category: null, query: null));
    });

    test('should handle error when loading news fails', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(mockGetNews.execute(
              category: anyNamed('category'), query: anyNamed('query')))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final notifier = container.read(newsProvider.notifier);
      await notifier.loadNews();

      // Assert
      final state = container.read(newsProvider);
      expect(state, isA<AsyncError>());
      expect(state.error, 'Server error');
      verify(mockGetNews.execute(category: null, query: null));
    });

    test('should load news with category', () async {
      // Arrange
      when(mockGetNews.execute(
              category: anyNamed('category'), query: anyNamed('query')))
          .thenAnswer((_) async => Right(tNewsList));

      // Act
      final notifier = container.read(newsProvider.notifier);
      notifier.setCategory('sports');
      await notifier.loadNews();

      // Assert
      final state = container.read(newsProvider);
      expect(state, AsyncValue.data(tNewsList));
      verify(mockGetNews.execute(category: 'sports', query: null));
    });

    test('should load news with query', () async {
      // Arrange
      when(mockGetNews.execute(
              category: anyNamed('category'), query: anyNamed('query')))
          .thenAnswer((_) async => Right(tNewsList));

      // Act
      final notifier = container.read(newsProvider.notifier);
      notifier.setQuery('tech');
      await notifier.loadNews();

      // Assert
      final state = container.read(newsProvider);
      expect(state, AsyncValue.data(tNewsList));
      verify(mockGetNews.execute(category: null, query: 'tech'));
    });

    test('should cancel request on dispose', () async {
      // Arrange
      final cancelToken = CancelToken();
      when(mockGetNews.execute(
              category: anyNamed('category'), query: anyNamed('query')))
          .thenAnswer((_) async => Right(tNewsList));

      // Act
      final provider = StateNotifierProvider.autoDispose<NewsNotifier,
          AsyncValue<List<News>>>((ref) {
        ref.onDispose(() => cancelToken.cancel());
        return NewsNotifier(mockGetNews, cancelToken);
      });
      final tempContainer = ProviderContainer(
          overrides: [getNewsProvider.overrideWithValue(mockGetNews)]);
      tempContainer.read(provider);
      tempContainer.dispose();

      // Assert
      expect(cancelToken.isCancelled, true);
    });
  });
}
