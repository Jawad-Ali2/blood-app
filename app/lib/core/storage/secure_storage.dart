import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();
  final String _accessTokenKey = "accessToken";
  final String _refreshTokenKey = "refreshToken";

  Future<void> setAccessToken(String accessToken) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      print("Token saved securely: $accessToken");
    } catch (e) {
      print("Error saving token: $e");
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      print("Error retrieving token: $e");
      return null;
    }
  }

  Future<void> setRefreshToken(String refreshToken) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      print("Token saved securely: $refreshToken");
    } catch (e) {
      print("Error saving token: $e");
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      print("Error retrieving token: $e");
      return null;
    }
  }

  Future<void> clearStorage() async {
    try {
      await _storage.deleteAll();
      print("Storage cleared successfully!");
    } catch (e) {
      print("Error clearing storage: $e");
    }
  }
}
