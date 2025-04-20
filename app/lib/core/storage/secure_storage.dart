import 'package:app/services/auth_services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorage {
  final _storage = const FlutterSecureStorage();
  final String _accessTokenKey = "accessToken";
  final String _refreshTokenKey = "refreshToken";
  final String _userKey = "user";

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

  Future<bool> hasAccessToken() async {
    try {
      return await _storage.containsKey(key: _accessTokenKey);
    } catch (e) {
      print("Error retrieving token: $e");
      return false;
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

  Future<bool> hasRefreshToken() async {
    try {
      return await _storage.containsKey(key: _refreshTokenKey);
    } catch (e) {
      print("Error retrieving token: $e");
      return false;
    }
  }

  Future<User?> getUser() async {
    try {
      String? userData = await _storage.read(key: _userKey);
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
    } catch (e) {
      print("Error retrieving token: $e");
      return null;
    }
    return null;
  }

  Future<String> getCurrentUserId() async {
    try {
      String? userData = await _storage.read(key: _userKey);
      if (userData != null) {
        return User.fromJson(jsonDecode(userData)).id;
      }
    } catch (e) {
      print("Error retrieving token: $e");
      return "";
    }
    return "";
  }

  Future<String> getUserBloodGroup() async {
    try {
      String? userData = await _storage.read(key: _userKey);
      if (userData != null) {
        return User.fromJson(jsonDecode(userData)).bloodGroup ?? "";
      }
    } catch (e) {
      print("Error retrieving token: $e");
    }
    return "";
  }

  Future<void> saveUser(User user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<void> clearAT() async {
    try {
      await _storage.delete(key: 'accessToken');
    } catch (e) {
      print("Error clearing storage: $e");
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
