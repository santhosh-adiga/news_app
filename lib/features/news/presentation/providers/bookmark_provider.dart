import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/di/injection_container.dart';
import 'package:news_app/features/news/domain/entities/news.dart';
import 'package:news_app/features/news/domain/usecases/add_bookmark.dart';
import 'package:news_app/features/news/domain/usecases/get_bookmarks.dart';
import 'package:news_app/features/news/domain/usecases/remove_bookmark.dart';

final getBookmarksProvider = Provider<GetBookmarks>((ref) => getIt.get<GetBookmarks>());
final addBookmarkProvider = Provider<AddBookmark>((ref) => getIt.get<AddBookmark>());
final removeBookmarkProvider = Provider<RemoveBookmark>((ref) => getIt.get<RemoveBookmark>());

final bookmarkProvider = StateNotifierProvider<BookmarkNotifier, AsyncValue<List<News>>>((ref) {
  return BookmarkNotifier(
    ref.read(getBookmarksProvider),
    ref.read(addBookmarkProvider),
    ref.read(removeBookmarkProvider),
  );
});

class BookmarkNotifier extends StateNotifier<AsyncValue<List<News>>> {
  final GetBookmarks getBookmarks;
  final AddBookmark addBookmark;
  final RemoveBookmark removeBookmark;

  BookmarkNotifier(this.getBookmarks, this.addBookmark, this.removeBookmark)
      : super(const AsyncValue.loading()) {
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    state = const AsyncValue.loading();
    final result = await getBookmarks.execute();
    state = result.fold(
          (failure) => AsyncValue.error(failure.message, StackTrace.current),
          (bookmarks) => AsyncValue.data(bookmarks),
    );
  }

  Future<void> add(News news) async {
    final result = await addBookmark.execute(news);
    result.fold(
          (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
          (_) => loadBookmarks(),
    );
  }

  Future<void> remove(String newsId) async {
    final result = await removeBookmark.execute(newsId);
    result.fold(
          (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
          (_) => loadBookmarks(),
    );
  }

  bool isBookmarked(String newsId) {
    return state.when(
      data: (bookmarks) => bookmarks.any((news) => news.id == newsId),
      loading: () => false,
      error: (_, __) => false,
    );
  }
}