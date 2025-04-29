import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/entities/news.dart';
import 'package:news_app/features/news/domain/usecases/add_bookmark.dart';

import '../../../../test_utils.mocks.dart';

void main() {
  late AddBookmark usecase;
  late MockNewsRepository mockRepository;

  setUp(() {
    mockRepository = MockNewsRepository();
    usecase = AddBookmark(mockRepository);
  });

  final tNews = News(
    id: '1',
    title: 'Test News',
    description: 'Description',
    source: 'Source',
    publishedAt: DateTime.now(),
  );

  group('AddBookmark', () {
    test('should add bookmark when repository call is successful', () async {
      // Arrange
      when(mockRepository.addBookmark(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase.execute(tNews);

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.addBookmark(tNews));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = CacheFailure('Cache error');
      when(mockRepository.addBookmark(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase.execute(tNews);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.addBookmark(tNews));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
