import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:news_app/core/network/network_info.dart';
import 'package:news_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_app/features/news/data/repositories/news_repository_impl.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/features/news/domain/usecases/add_bookmark.dart';
import 'package:news_app/features/news/domain/usecases/get_bookmarks.dart';
import 'package:news_app/features/news/domain/usecases/get_news.dart';
import 'package:news_app/features/news/domain/usecases/remove_bookmark.dart';

Future<void> initDependencies() async {
  // Network Info
  final networkInfo = NetworkInfoImpl(Connectivity());

  // Dio
  final dio = Dio();

  // Data Sources
  final remoteDataSource = NewsRemoteDataSourceImpl(dio);
  final localDataSource = await NewsLocalDataSourceImpl.create();

  // Repository
  final newsRepository = NewsRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );

  // Use Cases
  final getNews = GetNews(newsRepository);
  final getBookmarks = GetBookmarks(newsRepository);
  final addBookmark = AddBookmark(newsRepository);
  final removeBookmark = RemoveBookmark(newsRepository);

  // Store in global providers
  getIt.registerSingleton<NetworkInfo>(networkInfo);
  getIt.registerSingleton<NewsRemoteDataSource>(remoteDataSource);
  getIt.registerSingleton<NewsLocalDataSource>(localDataSource);
  getIt.registerSingleton<NewsRepository>(newsRepository);
  getIt.registerSingleton<GetNews>(getNews);
  getIt.registerSingleton<GetBookmarks>(getBookmarks);
  getIt.registerSingleton<AddBookmark>(addBookmark);
  getIt.registerSingleton<RemoveBookmark>(removeBookmark);
}

// Poor man's DI
class GetIt {
  final Map<Type, dynamic> _instances = {};

  void registerSingleton<T>(T instance) {
    _instances[T] = instance;
  }

  T get<T>() => _instances[T] as T;
}

final getIt = GetIt();