// import 'package:app/core/network/dio_client.dart';
// import 'package:app/core/storage/secure_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// // import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class DummyProfile extends StatefulWidget {
//   const DummyProfile({super.key});

//   @override
//   State<DummyProfile> createState() => _DummyProfileState();
// }

// class _DummyProfileState extends State<DummyProfile> {
//   final DioClient _dioClient = DioClient();
//   final _storage = SecureStorage();

//   String? username;
//   String? accessToken;
//   String? refreshToken;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     print("_--------------------------------------------");
//     _storage.getRefreshToken().then((token) {
//       print("Access Token: $token");
//     });

//     _fetchProfileData();
//   }

//   Future<void> _fetchProfileData() async {
//     try {
//       final at = await _storage.getAccessToken();
//       if (at == null) {
//         throw Exception("No access token found.");
//       }

//       _dioClient.dio.options.headers['Authorization'] = 'Bearer $at';

//       final response = await _dioClient.dio.get("/auth/profile");
//       final data = ProfileResponse.fromJson(response.data);

//       // Save updated tokens if they exist
//       // if (data.accessToken.isNotEmpty && data.refreshToken.isNotEmpty) {
//       //   await _storage.write(key: 'accessToken', value: data.accessToken);
//       //   await _storage.write(key: 'refreshToken', value: data.refreshToken);
//       // }

//       setState(() {
//         username = data.user.username;
//         accessToken = data.accessToken;
//         refreshToken = data.refreshToken;
//       });
//     } on DioException catch (dioError) {
//       setState(() {
//         errorMessage = dioError.response?.data["message"] ?? dioError.message;
//       });
//     } catch (e) {
//       setState(() {
//         errorMessage = "Error fetching profile data: $e";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Profile"),
//       ),
//       body: Center(
//         child: errorMessage != null
//             ? Text(errorMessage!)
//             : username == null
//                 ? const CircularProgressIndicator()
//                 : Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text("Welcome, $username"),
//                       const SizedBox(height: 10),
//                       Text("Access Token: ${accessToken ?? 'N/A'}"),
//                       const SizedBox(height: 10),
//                       Text("Refresh Token: ${refreshToken ?? 'N/A'}"),
//                     ],
//                   ),
//       ),
//     );
//   }
// }

// class ProfileResponse {
//   final User user;
//   final String accessToken;
//   final String refreshToken;

//   ProfileResponse({
//     required this.user,
//     required this.accessToken,
//     required this.refreshToken,
//   });

//   factory ProfileResponse.fromJson(Map<String, dynamic> json) {
//     return ProfileResponse(
//       user: User.fromJson(json['user']),
//       accessToken: json['accessToken'],
//       refreshToken: json['refreshToken'],
//     );
//   }
// }

// class User {
//   final String userId;
//   final String username;
//   final String email;
//   final List<String> role;

//   User({
//     required this.userId,
//     required this.username,
//     required this.email,
//     required this.role,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       userId: json['userId'],
//       username: json['username'],
//       email: json['email'],
//       role: List<String>.from(json['role']),
//     );
//   }
// }
