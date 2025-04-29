import 'package:either_dart/either.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/entities/news.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';

class GetBookmarks {
  final NewsRepository repository;

  GetBookmarks(this.repository);

  Future<Either<Failure, List<News>>> execute() async {
    return await repository.getBookmarks();
  }
}