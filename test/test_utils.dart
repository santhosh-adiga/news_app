import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/core/network/network_info.dart';
import 'package:news_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';

// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([
  NewsRepository,
  NewsRemoteDataSource,
  NewsLocalDataSource,
  NetworkInfo,
  Connectivity,
  Dio,
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