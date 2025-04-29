import 'package:either_dart/either.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/entities/news.dart';

abstract class NewsRepository {
  Future<Either<Failure, List<News>>> getNews(
      {String? category, String? query});
  Future<Either<Failure, List<News>>> getBookmarks();
  Future<Either<Failure, void>> addBookmark(News news);
  Future<Either<Failure, void>> removeBookmark(String newsId);
}
