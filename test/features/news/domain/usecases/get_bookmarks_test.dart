import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/entities/news.dart';
import 'package:news_app/features/news/domain/usecases/get_bookmarks.dart';

import '../../../../test_utils.mocks.dart';

void main() {
  late GetBookmarks usecase;
  late MockNewsRepository mockRepository;

  setUp(() {
    mockRepository = MockNewsRepository();
    usecase = GetBookmarks(mockRepository);
  });

  final tBookmarks = [
    News(
      id: '1',
      title: 'Bookmarked News',
      description: 'Description',
      source: 'Source',
      publishedAt: DateTime.now(),
    ),
  ];

  group('GetBookmarks', () {
    test('should return bookmarks when repository call is successful',
        () async {
      // Arrange
      when(mockRepository.getBookmarks())
          .thenAnswer((_) async => Right(tBookmarks));

      // Act
      final result = await usecase.execute();

      // Assert
      expect(result, Right(tBookmarks));
      verify(mockRepository.getBookmarks());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = CacheFailure('Cache error');
      when(mockRepository.getBookmarks())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase.execute();

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.getBookmarks());
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
