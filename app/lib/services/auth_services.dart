import 'package:app/core/network/dio_client.dart';
import 'package:app/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'dart:convert';

class User {
  final String id;
  final String username;
  final String email;
  final List<String> role;

  User(
      {required this.id,
      required this.username,
      required this.email,
      required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: List<String>.from(json['role']), // Ensure it's a List
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
    };
  }
}

class AuthService {
  final DioClient _dioClient = GetIt.instance.get<DioClient>();
  final SecureStorage _storage = GetIt.instance.get<SecureStorage>();

  Future<bool> isUserLoggedIn() async {
    String? token = await _storage.getAccessToken();

    if (token == null) return false;

    try {
      Response response = await _dioClient.dio.get('/auth/profile');

      if (response.statusCode == 200) {
        User user = User.fromJson(response.data);
        await _storage.saveUser(user);
        print("${response.data["username"]} ${response.statusCode}");
        return true;
      }

      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void setTokens(accessToken, refreshToken) {
    _storage.setAccessToken(accessToken);
    _storage.setRefreshToken(refreshToken);
  }
}
