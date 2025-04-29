
import 'package:either_dart/either.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/entities/news.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';

class AddBookmark {
  final NewsRepository repository;

  AddBookmark(this.repository);

  Future<Either<Failure, void>> execute(News news) async {
    return await repository.addBookmark(news);
  }
}