import 'package:app/core/network/dio_client.dart';
import 'package:app/core/storage/secure_storage.dart';
import 'package:app/services/notification_service.dart';
import 'package:app/widgets/custom_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'dart:convert';

class User {
  final String id;
  final String username;
  final String email;
  final List<String> role;
  final String bloodGroup;

  User(
      {required this.id,
      required this.username,
      required this.email,
      required this.role,
      this.bloodGroup = ""});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: List<String>.from(json['role']),
      bloodGroup: json['bloodGroup'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'bloodGroup': bloodGroup,
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

  Future<bool> signIn(email, password, context) async {
    try {
      final response = await _dioClient.dio
          .post("/auth/login", data: {"email": email, "password": password});

      if (response.statusCode == 200) {
        String accessToken = response.data['accessToken'];
        String refreshToken = response.data['refreshToken'];
        final User user = User.fromJson(response.data['user']);
        AuthService().setTokens(accessToken, refreshToken);
        _storage.saveUser(user);

        CustomToast.show(context,
            message: "User logged in successfully", isError: false);
      }

      return true;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          CustomToast.show(context,
              message: "Invalid email or password", isError: true);
        } else {
          CustomToast.show(context,
              message: "An error occurred. Please try again.", isError: true);
        }
      } else {
        CustomToast.show(context,
            message: "An error occurred. Please try again.", isError: true);
      }

      return false;
    }
  }

  Future<bool> signup(
      username,
      phone,
      email,
      cnic,
      city,
      coordinates,
      dateOfBirth,
      password,
      confirmPassword,
      isDonor,
      bloodGroup,
      medicalReportFile,
      context) async {
    try {
      final response = await _dioClient.dio.post("/auth/register", data: {
        "username": username,
        "phone": phone,
        "email": email,
        "cnic": cnic,
        "city": city,
        "coordinates": coordinates,
        "dob": dateOfBirth,
        "password": password,
        "confirmPassword": confirmPassword,
        "isDonor": isDonor,
        "bloodGroup": bloodGroup,
        "medicalReportFile": medicalReportFile,
      });
      if (response.statusCode == 201 && response.data["status"] == 'success') {
        CustomToast.show(
          context,
          message: "User registered successfully",
          isError: false,
        );
        if (bloodGroup.isNotEmpty) {
            await NotificationService.subscribeToBloodGroup(bloodGroup);
        }
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }

      if (e is DioException) {
        print(e.response);
        if (e.response?.statusCode == 400) {
          CustomToast.show(context,
              message: e.response?.data['message'], isError: true);
        } else if (e.response?.statusCode == 500) {
          CustomToast.show(context,
              message: "Server Error! Please try again later.", isError: true);
        }
      }

      return false;
    }
  }

  Future<bool> signOut(context) async {
    await _storage.clearStorage();

    // Optionally, you can also clear the DioClient's token
    final response = await _dioClient.dio.post('/auth/logout');

    if (response.statusCode == 200) {
      CustomToast.show(context,
          message: "User logged out successfully", isError: false);
      return true;
    } else {
      CustomToast.show(context, message: "Failed to log out!", isError: true);
      return false;
    }
  }

  Future<List<String>> getUserRoles(context) async {
    try {
      User? user = await _storage.getUser();

      List<String>? roles = user?.role;

      if (roles != null && roles.isNotEmpty) {
        return roles;
      } else {
        return [''];
      }
    } catch (e) {
      CustomToast.show(context, message: "$e", isError: true);
      return [''];
    }
  }

  void setTokens(accessToken, refreshToken) {
    _storage.setAccessToken(accessToken);
    _storage.setRefreshToken(refreshToken);
  }
}
