
import 'package:either_dart/either.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';

class RemoveBookmark {
  final NewsRepository repository;

  RemoveBookmark(this.repository);

  Future<Either<Failure, void>> execute(String newsId) async {
    return await repository.removeBookmark(newsId);
  }
}