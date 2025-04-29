import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/di/injection_container.dart';
import 'package:news_app/features/news/domain/entities/news.dart';
import 'package:news_app/features/news/domain/usecases/get_news.dart';

// Providers
final getNewsProvider = Provider<GetNews>((ref) => getIt.get<GetNews>());

final newsProvider =
    StateNotifierProvider.autoDispose<NewsNotifier, AsyncValue<List<News>>>(
        (ref) {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel()); // NFR 6: Cancel on dispose
  return NewsNotifier(ref.read(getNewsProvider), cancelToken);
});

class NewsNotifier extends StateNotifier<AsyncValue<List<News>>> {
  final GetNews getNews;
  final CancelToken cancelToken;
  String _category = '';
  String _query = '';

  NewsNotifier(this.getNews, this.cancelToken)
      : super(const AsyncValue.loading()) {
    loadNews();
    // NFR 8: Auto-retry on network restoration
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        loadNews();
      }
    });
  }

  void setCategory(String category) {
    _category = category;
    loadNews();
  }

  void setQuery(String query) {
    _query = query;
    loadNews();
  }

  Future<void> loadNews() async {
    state = const AsyncValue.loading(); // NFR 5: Unified loading state
    final result = await getNews.execute(
      category: _category.isEmpty ? null : _category,
      query: _query.isEmpty ? null : _query,
    );
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (news) => AsyncValue.data(news),
    );
  }

  Future<void> refresh() async {
    loadNews();
  }
}
