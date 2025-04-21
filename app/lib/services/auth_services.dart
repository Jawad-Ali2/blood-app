import 'package:app/core/network/dio_client.dart';
import 'package:app/core/storage/secure_storage.dart';
import 'package:app/services/notification_service.dart';
import 'package:app/widgets/custom_toast.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';
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
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  String? _verificationId;
  int? _resendToken;

  // For email verification
  firebase_auth.User? _tempEmailUser;
  Timer? _checkEmailVerifiedTimer;

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

  Future<void> verifyPhoneNumber(String phoneNumber,
      {Function(String, int?)? onCodeSent, Function(String)? onError}) async {
    final formattedPhoneNumber = phoneNumber.startsWith("03")
        ? "+92${phoneNumber.substring(1)}"
        : phoneNumber;

    print(formattedPhoneNumber);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted:
            (firebase_auth.PhoneAuthCredential credential) async {
          // Auto-verification completed (rare on most devices)
          firebase_auth.UserCredential userCredential =
              await _auth.signInWithCredential(credential);
          await handleVerifiedUser(userCredential);
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
          if (onError != null) {
            onError(e.message ?? "Verification failed");
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          print('Code sent to $formattedPhoneNumber');
          _verificationId = verificationId;
          _resendToken = resendToken;
          if (onCodeSent != null) {
            onCodeSent(verificationId, resendToken);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Auto-retrieval timeout.');
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      print('Error sending verification code: $e');
      if (onError != null) {
        onError(e.toString());
      }
    }
  }

  Future<bool> verifyOtp(String smsCode,
      {Function()? onSuccess, Function(String)? onError}) async {
    try {
      if (_verificationId == null) {
        if (onError != null) {
          onError("Verification ID not found. Please request OTP again.");
        }
        return false;
      }

      firebase_auth.PhoneAuthCredential credential =
          firebase_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      firebase_auth.UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      await handleVerifiedUser(userCredential);

      if (onSuccess != null) {
        onSuccess();
      }
      return true;
    } catch (e) {
      print('OTP verification failed: $e');
      if (onError != null) {
        String errorMessage = "Invalid verification code";
        if (e is firebase_auth.FirebaseAuthException) {
          errorMessage = e.message ?? errorMessage;
        }
        onError(errorMessage);
      }
      return false;
    }
  }

  Future<void> handleVerifiedUser(
      firebase_auth.UserCredential userCredential) async {
    String? phone = userCredential.user?.phoneNumber;
    print('✅ Verified phone number: $phone');

    // ✅ Optional: Send token to backend if needed
    String? idToken = await userCredential.user?.getIdToken();
    print('User token: $idToken');

    // ✅ Immediately delete the user from Firebase Auth
    await userCredential.user?.delete();
    print('✅ User deleted after verification');
  }

  // Check if email already exists in your backend
  Future<bool> checkEmailExists(String email) async {
    try {
      // TODO: Implement actual backend check
      // Example implementation:
      /*
      final response = await _dioClient.dio.post("/auth/check-email", data: {
        "email": email
      });
      return response.data['exists'] == true;
      */

      // For now, return false (email doesn't exist)
      return false;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  Future<bool> sendEmailVerification(String email,
      {Function()? onEmailSent, Function(String)? onError}) async {
    try {
      // Check if email exists in backend before proceeding
      bool emailExists = await checkEmailExists(email);
      if (emailExists) {
        if (onError != null) {
          onError(
              "This email is already registered. Please use a different email.");
        }
        return false;
      }

      // Create a temporary user with email
      firebase_auth.UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        // Using a random password since we'll delete this user afterward
        password: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      // Send verification email
      await userCredential.user!.sendEmailVerification();
      _tempEmailUser = userCredential.user;

      if (onEmailSent != null) {
        onEmailSent();
      }

      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = 'An error occurred.';

      if (e.code == 'email-already-in-use') {
        message =
            'This email is already registered. Please use a different email.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else {
        message = e.message ?? message;
      }

      if (onError != null) {
        onError(message);
      }

      return false;
    } catch (e) {
      if (onError != null) {
        onError(e.toString());
      }
      return false;
    }
  }

  Future<bool> resendEmailVerification(
      {Function()? onEmailSent, Function(String)? onError}) async {
    try {
      if (_tempEmailUser == null) {
        if (onError != null) {
          onError(
              "No email verification in progress. Please start a new verification.");
        }
        return false;
      }

      await _tempEmailUser!.sendEmailVerification();

      if (onEmailSent != null) {
        onEmailSent();
      }

      return true;
    } catch (e) {
      if (onError != null) {
        onError(e.toString());
      }
      return false;
    }
  }

  void startEmailVerificationCheck({
    Function()? onVerified,
    Function()? onTimeout,
    int timeoutSeconds = 300, // 5 minutes timeout
  }) {
    if (_tempEmailUser == null) return;

    _checkEmailVerifiedTimer?.cancel();

    int elapsedSeconds = 0;
    _checkEmailVerifiedTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) async {
        // Check for timeout
        elapsedSeconds += 3;
        if (elapsedSeconds > timeoutSeconds) {
          timer.cancel();
          if (onTimeout != null) {
            onTimeout();
          }
          return;
        }

        // Reload user to get updated verification status
        try {
          await _tempEmailUser!.reload();

          // Get the refreshed user
          firebase_auth.User? refreshedUser = _auth.currentUser;

          if (refreshedUser != null && refreshedUser.emailVerified) {
            timer.cancel();

            if (onVerified != null) {
              onVerified();
            }

            // Clean up after verification
            cleanupEmailVerification();
          }
        } catch (e) {
          print('Error checking email verification: $e');
        }
      },
    );
  }

  void cleanupEmailVerification() {
    // Delete the temporary user if it exists
    _tempEmailUser?.delete();
    _tempEmailUser = null;
    _checkEmailVerifiedTimer?.cancel();
    _checkEmailVerifiedTimer = null;
  }
}
