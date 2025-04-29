import 'package:either_dart/either.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/core/network/network_info.dart';
import 'package:news_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_app/features/news/data/models/news_model.dart';
import 'package:news_app/features/news/domain/entities/news.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final Map<String, DateTime> _lastFetched = {};
  final Map<String, List<News>> _cachedNews = {};

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  String _getCacheKey({String? category, String? query}) {
    return '${category ?? 'general'}_${query ?? ''}';
  }

  @override
  Future<Either<Failure, List<News>>> getNews({
    String? category,
    String? query,
  }) async {
    final cacheKey = _getCacheKey(category: category, query: query);

    // NFR 2: Cache for 10 minutes
    if (_lastFetched[cacheKey] != null &&
        DateTime.now().difference(_lastFetched[cacheKey]!).inMinutes < 10 &&
        _cachedNews[cacheKey] != null) {
      return Right(_cachedNews[cacheKey]!);
    }

    // NFR 7: Show cached data if offline
    if (await networkInfo.isConnected) {
      try {
        final remoteNews = await remoteDataSource.getNews(
          category: category,
          query: query,
        );
        await localDataSource.cacheNews(remoteNews, cacheKey);
        _cachedNews[cacheKey] = remoteNews;
        _lastFetched[cacheKey] = DateTime.now();
        return Right(remoteNews);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final cachedNews = await localDataSource.getCachedNews(cacheKey);
        if (cachedNews.isNotEmpty) {
          _cachedNews[cacheKey] = cachedNews;
          return Right(cachedNews);
        }
        return const Left(NetworkFailure('No network and no cached data'));
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<News>>> getBookmarks() async {
    try {
      final bookmarks = await localDataSource.getBookmarks();
      return Right(bookmarks);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addBookmark(News news) async {
    try {
      await localDataSource.addBookmark(NewsModel(
        id: news.id,
        title: news.title,
        description: news.description,
        source: news.source,
        imageUrl: news.imageUrl,
        content: news.content,
        publishedAt: news.publishedAt,
      ));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeBookmark(String newsId) async {
    try {
      await localDataSource.removeBookmark(newsId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
