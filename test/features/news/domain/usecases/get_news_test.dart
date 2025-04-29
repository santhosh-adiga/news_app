import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/entities/news.dart';
import 'package:news_app/features/news/domain/usecases/get_news.dart';

import '../../../../test_utils.mocks.dart';

void main() {
  late GetNews usecase;
  late MockNewsRepository mockRepository;

  setUp(() {
    mockRepository = MockNewsRepository();
    usecase = GetNews(mockRepository);
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

  group('GetNews', () {
    test('should return news list when repository call is successful',
        () async {
      // Arrange
      when(mockRepository.getNews(
              category: anyNamed('category'), query: anyNamed('query')))
          .thenAnswer((_) async => Right(tNewsList));

      // Act
      final result = await usecase.execute(category: 'general', query: 'test');

      // Assert
      expect(result, Right(tNewsList));
      verify(mockRepository.getNews(category: 'general', query: 'test'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(mockRepository.getNews(
              category: anyNamed('category'), query: anyNamed('query')))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase.execute();

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.getNews(category: null, query: null));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
