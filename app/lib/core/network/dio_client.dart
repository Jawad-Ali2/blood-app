import 'dart:async';

import 'package:app/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class DioClient {
  final Dio dio = Dio();

  final _storage = GetIt.instance.get<SecureStorage>();
  bool isRefreshing = false;

  DioClient() {
    dio
      // ..options.baseUrl = "http://localhost:3000"
      // ..options.baseUrl = 'https://blood-app-production.up.railway.app'
      ..options.baseUrl = 'http://10.4.28.139:3000'
      // ..options.baseUrl = 'http://192.168.8.115:3000'
      ..options.connectTimeout = Duration(seconds: 5000)
      ..options.receiveTimeout = Duration(seconds: 3000);

    _initializeHeaders();

    // dio.interceptors.add(LogInterceptor());
    // Interceptors
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      print("Request: ${options.uri} ${options.method}");
      final accessToken = await _storage.getAccessToken();
      print('pre request token::::::: $accessToken');
      if (accessToken != null) {
        dio.options.headers['Authorization'] = 'Bearer $accessToken';
      }

      return handler.next(options);
    }, onResponse: (response, handler) async {
      return handler.next(response);
    }, onError: (DioException error, handler) async {
      if (error.response?.statusCode == 401) {
        print(
            "returned status: ${error.response?.statusCode}, ${await _storage.getRefreshToken()} at: ${await _storage.getAccessToken()}");
        if (!isRefreshing) {
          isRefreshing = true;

          if (await _storage.hasRefreshToken()) {
            // Unauthorized error meaning token has expired
            final newAccessToken = await refreshToken();
            isRefreshing = false;

            if (newAccessToken != null) {
              print("_________ TOKEN REFRESHED SUCCESSFULLY ___________");
              dio.options.headers['Authorization'] = 'Bearer $newAccessToken';

              // Update the request headers before retrying
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';

              return handler.resolve(await _retry(error.requestOptions));
            }
          }
        }

        print("_________ THIS GOT CALLED ___________");
        await _storage.clearStorage();
        return handler.reject(error);
      }
      print("Error $error");

      return handler.next(error);
    }));
  }

  Future<void> _initializeHeaders() async {
    String? token = await _storage.getAccessToken();
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options =
        Options(method: requestOptions.method, headers: requestOptions.headers);

    return dio.request<dynamic>(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options);
  }

  Future<String?> refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      final response = await dio
          .post('/auth/refresh-token', data: {'refreshToken': refreshToken});

      print(response);

      if (response.statusCode == 201) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];

        _storage.setAccessToken(newAccessToken);
        _storage.setRefreshToken(newRefreshToken);

        return newAccessToken;
      } else {
        await _storage.clearStorage();
      }
    } catch (e) {
      await _storage.clearStorage();
    }

    return null;
  }

  String _extractToken(String cookie) {
    print("__________----------___________ $cookie");
    return cookie.split(';').first.split('=').last;
  }
}
