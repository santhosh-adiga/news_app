import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/core/network/network_info.dart';

import '../../test_utils.mocks.dart';

void main() {
  late NetworkInfoImpl networkInfo;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockConnectivity = MockConnectivity();
    networkInfo = NetworkInfoImpl(mockConnectivity);
  });

  group('NetworkInfoImpl', () {
    test('should return true when connected via wifi', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      // Act
      final result = await networkInfo.isConnected;

      // Assert
      expect(result, true);
      verify(mockConnectivity.checkConnectivity());
    });

    test('should return true when connected via mobile', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);

      // Act
      final result = await networkInfo.isConnected;

      // Assert
      expect(result, true);
      verify(mockConnectivity.checkConnectivity());
    });

    test('should return false when not connected', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      // Act
      final result = await networkInfo.isConnected;

      // Assert
      expect(result, false);
      verify(mockConnectivity.checkConnectivity());
    });

    test('should return true when multiple connections are active', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity()).thenAnswer(
          (_) async => [ConnectivityResult.wifi, ConnectivityResult.mobile]);

      // Act
      final result = await networkInfo.isConnected;

      // Assert
      expect(result, true);
      verify(mockConnectivity.checkConnectivity());
    });
  });
}
