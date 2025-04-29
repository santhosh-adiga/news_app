import 'package:dio/dio.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/data/models/news_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsModel>> getNews({
    String? category,
    String? query,
    CancelToken? cancelToken,
  });
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final Dio dio;

  NewsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<NewsModel>> getNews({
    String? category,
    String? query,
    CancelToken? cancelToken,
  }) async {
    try {
      final apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        throw const ServerFailure('API key is missing');
      }
      final url = StringBuffer('https://newsapi.org/v2/top-headlines?apiKey=$apiKey');
      url.write('&country=us');
      if (category != null && category.isNotEmpty) {
        url.write('&category=$category');
      }
      if (query != null && query.isNotEmpty) {
        url.write('&q=$query');
      }
      final response = await dio.get(url.toString(), cancelToken: cancelToken);
      return (response.data['articles'] as List)
          .map((json) => NewsModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to fetch news: $e');
    }
  }
}