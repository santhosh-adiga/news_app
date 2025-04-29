import 'package:hive/hive.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/data/models/news_model.dart';

abstract class NewsLocalDataSource {
  Future<List<NewsModel>> getCachedNews(String cacheKey);
  Future<void> cacheNews(List<NewsModel> news, String cacheKey);
  Future<List<NewsModel>> getBookmarks();
  Future<void> addBookmark(NewsModel news);
  Future<void> removeBookmark(String newsId);
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  static const String newsBoxName = 'newsBox';
  static const String bookmarkBoxName = 'bookmarkBox';

  NewsLocalDataSourceImpl();

  static Future<NewsLocalDataSourceImpl> create() async {
    if (!Hive.isBoxOpen(newsBoxName)) {
      await Hive.openBox<List<NewsModel>>(newsBoxName); // Store lists
    }
    if (!Hive.isBoxOpen(bookmarkBoxName)) {
      await Hive.openBox<NewsModel>(bookmarkBoxName); // Store single NewsModel
    }
    return NewsLocalDataSourceImpl();
  }

  Future<Box<List<NewsModel>>> _openNewsBox() async {
    return Hive.box<List<NewsModel>>(newsBoxName);
  }

  Future<Box<NewsModel>> _openBookmarkBox() async {
    return Hive.box<NewsModel>(bookmarkBoxName);
  }

  @override
  Future<List<NewsModel>> getCachedNews(String cacheKey) async {
    try {
      final box = await _openNewsBox();
      final cached = box.get(cacheKey, defaultValue: <NewsModel>[]);
      return cached ?? [];
    } catch (e) {
      throw const CacheFailure('Failed to retrieve cached news');
    }
  }

  @override
  Future<void> cacheNews(List<NewsModel> news, String cacheKey) async {
    try {
      final box = await _openNewsBox();
      await box.put(cacheKey, news);
    } catch (e) {
      throw const CacheFailure('Failed to cache news');
    }
  }

  @override
  Future<List<NewsModel>> getBookmarks() async {
    try {
      final box = await _openBookmarkBox();
      return box.values.toList();
    } catch (e) {
      throw const CacheFailure('Failed to retrieve bookmarks');
    }
  }

  @override
  Future<void> addBookmark(NewsModel news) async {
    try {
      final box = await _openBookmarkBox();
      await box.put(news.id, news);
    } catch (e) {
      throw const CacheFailure('Failed to add bookmark');
    }
  }

  @override
  Future<void> removeBookmark(String newsId) async {
    try {
      final box = await _openBookmarkBox();
      await box.delete(newsId);
    } catch (e) {
      throw const CacheFailure('Failed to remove bookmark');
    }
  }
}