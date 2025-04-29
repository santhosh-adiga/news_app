
import 'package:either_dart/either.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/entities/news.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';

class GetNews {
  final NewsRepository repository;

  GetNews(this.repository);

  Future<Either<Failure, List<News>>> execute({String? category, String? query}) async {
    return await repository.getNews(category: category, query: query);
  }
}