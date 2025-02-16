import 'package:app/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  final Dio dio = Dio();

  // final SecureStorage _storage = SecureStorage();
  final _storage = GetIt.instance.get<SecureStorage>();

  DioClient() {
    dio
      // ..options.baseUrl = "http://localhost:3000"
      ..options.baseUrl = 'http://192.168.1.59:3000'
      ..options.connectTimeout = Duration(seconds: 5000)
      ..options.receiveTimeout = Duration(seconds: 3000);

    // dio.interceptors.add(LogInterceptor());
    // Interceptors
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      print("Request: ${options.uri}");
      return handler.next(options);
    }, onResponse: (response, handler) async {
      final accessToken = response.data["accessToken"];
      final refreshToken = response.data["refreshToken"];
      print("__________----------___________ $accessToken $refreshToken");

      _storage.setAccessToken(accessToken);
      _storage.setRefreshToken(refreshToken);

      final cookies = response.headers['set-cookie'];
      print("__________----------___________ $cookies");

      if (cookies != null && cookies.isNotEmpty) {
        for (var cookie in cookies) {
          if (cookie.contains('at')) {
            final accessToken = _extractToken(cookie);

            await _storage.setAccessToken(accessToken);
          } else if (cookie.contains('rt')) {
            final refreshToken = _extractToken(cookie);

            await _storage.setRefreshToken(refreshToken);
          }
        }
      }
      return handler.next(response);
    }, onError: (DioException error, handler) {
      print("Error $error");

      return handler.next(error);
    }));
  }

  String _extractToken(String cookie) {
    print("__________----------___________ $cookie");
    return cookie.split(';').first.split('=').last;
  }
}
