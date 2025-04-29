import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/usecases/remove_bookmark.dart';

import '../../../../test_utils.mocks.dart';

void main() {
  late RemoveBookmark usecase;
  late MockNewsRepository mockRepository;

  setUp() {
    mockRepository = MockNewsRepository();
    usecase = RemoveBookmark(mockRepository);
  }

  const tNewsId = '1';

  group('RemoveBookmark', () {
    test('should remove bookmark when repository call is successful', () async {
      // Arrange
      when(mockRepository.removeBookmark(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase.execute(tNewsId);

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.removeBookmark(tNewsId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = CacheFailure('Cache error');
      when(mockRepository.removeBookmark(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase.execute(tNewsId);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.removeBookmark(tNewsId));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
