import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_app/features/news/data/models/news_model.dart';

import '../../../../test_utils.dart';

void main() {
  late NewsRemoteDataSourceImpl dataSource;
  late Dio dio;
  late DioAdapter dioAdapter;

  setUp(() async {
    dio = Dio();
    dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;
    dataSource = NewsRemoteDataSourceImpl(dio);
    await dotenv.load(fileName: '.env');
    dotenv.testLoad(fileInput: 'NEWS_API_KEY=test_key');
  });

  group('NewsRemoteDataSourceImpl', () {
    final tNewsList = [
      NewsModel(
        id: 'http://example.com/ai',
        title: 'New AI Breakthrough',
        description: 'AI advances in 2025.',
        source: 'TechCrunch',
        imageUrl: 'http://example.com/ai.jpg',
        content: 'Full AI content.',
        publishedAt: DateTime.parse('2025-04-14T10:00:00Z'),
      ),
    ];

    test('should return list of news when API call is successful', () async {
      // Arrange
      final fixture = await loadFixture('news_response.json');
      dioAdapter.onGet(
        'https://newsapi.org/v2/top-headlines?apiKey=test_key&country=us',
        (server) => server.reply(200, jsonDecode(fixture)),
      );

      // Act
      final result = await dataSource.getNews();

      // Assert
      expect(result, isA<List<NewsModel>>());
      expect(result.length, tNewsList.length);
      expect(result.first.title, tNewsList.first.title);
    });

    test('should throw ServerFailure when API call fails', () async {
      // Arrange
      dioAdapter.onGet(
        'https://newsapi.org/v2/top-headlines?apiKey=test_key&country=us',
        (server) => server.reply(500, {'error': 'Server error'}),
      );

      // Act & Assert
      expect(() => dataSource.getNews(), throwsA(isA<ServerFailure>()));
    });

    test('should include category in URL when provided', () async {
      // Arrange
      final fixture = await loadFixture('news_response.json');
      dioAdapter.onGet(
        'https://newsapi.org/v2/top-headlines?apiKey=test_key&country=us&category=sports',
        (server) => server.reply(200, jsonDecode(fixture)),
      );

      // Act
      final result = await dataSource.getNews(category: 'sports');

      // Assert
      expect(result, isA<List<NewsModel>>());
    });

    test('should include query in URL when provided', () async {
      // Arrange
      final fixture = await loadFixture('news_response.json');
      dioAdapter.onGet(
        'https://newsapi.org/v2/top-headlines?apiKey=test_key&country=us&q=tech',
        (server) => server.reply(200, jsonDecode(fixture)),
      );

      // Actimport 'package:dartz/dartz.dart';
      final result = await dataSource.getNews(query: 'tech');

      // Assert
      expect(result, isA<List<NewsModel>>());
    });
  });
}
