import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/core/network/network_info.dart';
import 'package:news_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/features/news/domain/usecases/add_bookmark.dart';
import 'package:news_app/features/news/domain/usecases/get_bookmarks.dart';
import 'package:news_app/features/news/domain/usecases/get_news.dart';
import 'package:news_app/features/news/domain/usecases/remove_bookmark.dart';

// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([
  NewsRepository,
  NewsRemoteDataSource,
  NewsLocalDataSource,
  Connectivity,
  Dio,
  GetNews,
  GetBookmarks,
  AddBookmark,
  RemoveBookmark,
])
void main() {}

class MockNetworkInfoImpl extends Mock implements NetworkInfo {
  @override
  Future<bool> get isConnected => super.noSuchMethod(
        Invocation.getter(#isConnected),
        returnValue: Future.value(true),
        returnValueForMissingStub: Future.value(true),
      );
}

Future<String> loadFixture(String path) async {
  return File('test/fixtures/$path').readAsString();
}
