import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/navigator_service.dart';
import 'package:lms/data/local_data_source/local_data_sourse.dart';
import 'package:lms/presentation/widgets/app_snake_bar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final http.Client _client;
  final AuthLocalDataSource localDataSource;
  ApiClient({http.Client? client, required this.localDataSource})
    : _client = client ?? http.Client();

  // ================== GET DATA Handle ==================
  Future<Either<Failure, Map<String, dynamic>>> get(
    String? url, {
    bool requiresAuth = true,
  }) async {
    /// ✅ Validate URL
    if (url == null || url.isEmpty) {
      return Left(ClientFailure('Invalid API URL'));
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      print('access token mmmmmmmmmmmmmmmmm : ${accessToken}');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (requiresAuth && accessToken != null)
          'Authorization': 'Bearer $accessToken',
      };

      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      /// ================= HANDLE 401 =================
      if (response.statusCode == 401 && requiresAuth) {
        print('Received 401 Unauthorized. Attempting to refresh token...');
        final refreshed = await _refreshToken();
        if (refreshed) {
          accessToken = prefs.getString('accessToken');

          final retryHeaders = <String, String>{
            'Content-Type': 'application/json',
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          };

          final retryResponse = await _client
              .get(Uri.parse(url), headers: retryHeaders)
              .timeout(const Duration(seconds: 20));

          return handleResponse(retryResponse);
        } else {
          print('Session expired. Logging out user.');
          await _forceLogout();
          return Left(AuthFailure('Session expired'));
        }
      }

      return handleResponse(response);
    }
    /// ================= TIMEOUT =================
    on TimeoutException {
      return Left(NetworkFailure('Request timed out'));
    }
    /// ================= NO INTERNET =================
    on SocketException {
      print('No internet connection');
      return Left(NetworkFailure('No internet connection'));
    }
    /// ================= UNKNOWN ERROR =================
    catch (e) {
      return Left(OtherFailureNon200('Unexpected error occurred'));
    }
  }

  // ================== POST DATA Handle ==================
  Future<Either<Failure, Map<String, dynamic>>> post(
    String? url, {
    Map<String, dynamic>? body,
    Map<String, String>? files, // 🔥 STRING PATH SUPPORT
    bool requiresAuth = true,
  }) async {
    if (url == null || url.isEmpty) {
      return Left(ClientFailure('Invalid API URL'));
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      print('access token : ${accessToken}');

      /// ================= MULTIPART =================
      if (files != null && files.isNotEmpty) {
        print(
          'Preparing multipart request for $url with body: $body and files: $files',
        );
        final request = http.MultipartRequest('POST', Uri.parse(url));

        if (requiresAuth && accessToken != null) {
          request.headers['Authorization'] = 'Bearer $accessToken';
        }

        /// 🔥 Add normal fields
        if (body != null) {
          body.forEach((key, value) {
            request.fields[key] = value.toString();
          });
        }

        for (var entry in files.entries) {
          final fieldName = entry.key;
          final rawPath = entry.value;

          if (rawPath.isEmpty) continue;

          final cleanedPath = rawPath
              .replaceAll("File: '", "")
              .replaceAll("'", "");

          final file = File(cleanedPath);

          if (await file.exists()) {
            final bytes = await file.readAsBytes();

            request.files.add(
              http.MultipartFile.fromBytes(
                fieldName,
                bytes,
                filename: file.path.split('/').last,
                contentType: getMediaType(file.path),
              ),
            );
          }
        }
        // /// 🔥 Convert STRING → FILE → Upload
        // for (var entry in files.entries) {
        //   final fieldName = entry.key;
        //   final rawPath = entry.value;

        //   if (rawPath.isEmpty) continue;

        //   final cleanedPath = rawPath
        //       .replaceAll("File: '", "")
        //       .replaceAll("'", "");

        //   final file = File(cleanedPath);

        //   if (await file.exists()) {
        //     request.files.add(
        //       await http.MultipartFile.fromPath(fieldName, file.path),
        //     );
        //   }
        // }

        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 20),
        );

        final response = await http.Response.fromStream(streamedResponse);

        /// ================= HANDLE 401 =================
        if (response.statusCode == 401 && requiresAuth) {
          final refreshed = await _refreshToken();

          if (refreshed) {
            return post(
              url,
              body: body,
              files: files,
              requiresAuth: requiresAuth,
            );
          } else {
            await _forceLogout();
            return Left(AuthFailure('Session expired'));
          }
        }

        return handleResponse(response);
      }

      /// ================= NORMAL JSON =================
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (requiresAuth && accessToken != null)
          'Authorization': 'Bearer $accessToken',
      };

      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _refreshToken();

        if (refreshed) {
          accessToken = prefs.getString('accessToken');

          final retryHeaders = <String, String>{
            'Content-Type': 'application/json',
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          };

          final retryResponse = await _client
              .post(
                Uri.parse(url),
                headers: retryHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(const Duration(seconds: 20));

          return handleResponse(retryResponse);
        } else {
          await _forceLogout();
          return Left(AuthFailure('Session expired'));
        }
      }
      print('aaaaaaaaaaaaaaa :${response.body}');
      return handleResponse(response);
    } on TimeoutException {
      return Left(AuthFailure('Request timed out'));
    } on SocketException {
      return Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(OtherFailureNon200('Unexpected error occurred'));
    }
  }

  // ================== PUT DATA Handle ==================
  Future<Either<Failure, Map<String, dynamic>>> put(
    String? url, {
    Map<String, dynamic>? body,
    Map<String, String>? files,
    bool requiresAuth = true,
  }) async {
    if (url == null || url.isEmpty) {
      return Left(ClientFailure('Invalid API URL'));
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      /// ================= MULTIPART =================
      if (files != null && files.isNotEmpty) {
        print(
          'Preparing multipart PUT request for $url with body: $body and files: $files',
        );

        final request = http.MultipartRequest('PUT', Uri.parse(url));

        if (requiresAuth && accessToken != null) {
          request.headers['Authorization'] = 'Bearer $accessToken';
        }

        /// 🔥 Add normal fields
        if (body != null) {
          body.forEach((key, value) {
            request.fields[key] = value.toString();
            print('Added field: $key = ${value.toString()}');
          });
        }

        /// 🔥 Convert STRING → FILE → Upload
        for (var entry in files.entries) {
          final fieldName = entry.key;
          final rawPath = entry.value;

          if (rawPath.isEmpty) continue;

          final cleanedPath = rawPath
              .replaceAll("File: '", "")
              .replaceAll("'", "");

          final file = File(cleanedPath);
          print(
            'Processing file for field: $fieldName with path: $cleanedPath',
          );
          log('File exists: ${file.path}');
          // if (await file.exists()) {
          //   request.files.add(
          //     await http.MultipartFile.fromPath(fieldName, file.path),
          //   );
          // }
          if (await file.exists()) {
            final imageBytes = await file.readAsBytes();
            request.files.add(
              http.MultipartFile.fromBytes(
                fieldName,
                imageBytes,
                filename: file.path.split('/').last,
                contentType: http.MediaType(
                  'image',
                  'jpg',
                ), // Adjust based on your file type
              ),
            );
          }
        }

        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 20),
        );

        final response = await http.Response.fromStream(streamedResponse);

        /// ================= HANDLE 401 =================
        if (response.statusCode == 401 && requiresAuth) {
          final refreshed = await _refreshToken();

          if (refreshed) {
            return put(
              url,
              body: body,
              files: files,
              requiresAuth: requiresAuth,
            );
          } else {
            await _forceLogout();
            return Left(AuthFailure('Session expired'));
          }
        }

        return handleResponse(response);
      }

      /// ================= NORMAL JSON =================
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (requiresAuth && accessToken != null)
          'Authorization': 'Bearer $accessToken',
      };

      final response = await _client
          .put(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 20));

      /// ================= HANDLE 401 =================
      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _refreshToken();

        if (refreshed) {
          accessToken = prefs.getString('accessToken');

          final retryHeaders = <String, String>{
            'Content-Type': 'application/json',
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          };

          final retryResponse = await _client
              .put(
                Uri.parse(url),
                headers: retryHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(const Duration(seconds: 20));

          return handleResponse(retryResponse);
        } else {
          await _forceLogout();
          return Left(AuthFailure('Session expired'));
        }
      }

      return handleResponse(response);
    } on TimeoutException {
      return Left(NetworkFailure('Request timed out'));
    } on SocketException {
      return Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(OtherFailureNon200('Unexpected error occurred'));
    }
  }

  // ================== DELETE DATA Handle ==================
  Future<Either<Failure, Map<String, dynamic>>> delete(
    String? url, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    if (url == null || url.isEmpty) {
      return Left(ClientFailure('Invalid API URL'));
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (requiresAuth && accessToken != null)
          'Authorization': 'Bearer $accessToken',
      };

      final response = await _client
          .delete(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 20));

      /// ================= HANDLE 401 =================
      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _refreshToken();

        if (refreshed) {
          accessToken = prefs.getString('accessToken');

          final retryHeaders = <String, String>{
            'Content-Type': 'application/json',
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          };

          final retryResponse = await _client
              .delete(
                Uri.parse(url),
                headers: retryHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(const Duration(seconds: 20));

          return handleResponse(retryResponse);
        } else {
          await _forceLogout();
          return Left(AuthFailure('Session expired'));
        }
      }

      return handleResponse(response);
    } on TimeoutException {
      return Left(NetworkFailure('Request timed out'));
    } on SocketException {
      return Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(OtherFailureNon200('Unexpected error occurred'));
    }
  }

  // ================== PATCH DATA Handle ==================
  Future<Either<Failure, Map<String, dynamic>>> patch(
    String? url, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    if (url == null || url.isEmpty) {
      return Left(ClientFailure('Invalid API URL'));
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (requiresAuth && accessToken != null)
          'Authorization': 'Bearer $accessToken',
      };

      final response = await _client
          .patch(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 20));

      // ================= HANDLE 401 =================
      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _refreshToken();

        if (refreshed) {
          accessToken = prefs.getString('accessToken');

          final retryHeaders = <String, String>{
            'Content-Type': 'application/json',
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          };

          final retryResponse = await _client
              .patch(
                Uri.parse(url),
                headers: retryHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(const Duration(seconds: 20));

          return handleResponse(retryResponse);
        } else {
          await _forceLogout();
          return Left(AuthFailure('Session expired'));
        }
      }

      return handleResponse(response);
    } on TimeoutException {
      return Left(NetworkFailure('Request timed out'));
    } on SocketException {
      return Left(NetworkFailure('No internet connection'));
    } catch (e) {
      log('PATCH request error: $e');
      return Left(OtherFailureNon200('Unexpected error occurred'));
    }
  }

  // ================== REFRESH TOKEN Handle ==================
  Future<bool> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');
    print('refreshtokenaaaaaaaaaaaaaaaaa : ${refreshToken}');
    if (refreshToken == null) return false;

    final response = await _client.post(
      Uri.parse('${ApiEndPoint.baseUrl}${ApiEndPoint.refreshTokenEndPoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await prefs.setString('accessToken', data['data']['accessToken']);
      await prefs.setString('refreshToken', data['data']['refreshToken']);
      return true;
    }
    return false;
  }

  // ================== Handle Response errro handle ==================
  Future<Either<Failure, Map<String, dynamic>>> handleResponse(
    http.Response? response,
  ) async {
    /// ✅ Null response safety
    if (response == null) {
      return Left(OtherFailureNon200('No response from server'));
    }

    final int statusCode = response.statusCode;
    print('sssssssssssss : ${response.body}');
    Map<String, dynamic>? decoded;

    try {
      if (response.body.isNotEmpty) {
        final dynamic body = jsonDecode(response.body);

        if (body is Map<String, dynamic>) {
          decoded = body;
        } else {
          return Left(OtherFailureNon200('Unexpected response format'));
        }
      }
    } on FormatException {
      return Left(OtherFailureNon200('Invalid JSON format'));
    }

    /// ================= SUCCESS =================
    if (statusCode >= 200 && statusCode < 300) {
      return Right(decoded ?? <String, dynamic>{});
    }

    /// ================= 401 =================
    if (statusCode == 401) {
      final message = decoded?['message']?.toString() ?? 'Unauthorized access';
      return Left(AuthFailure(message));
    }

    /// ================= CLIENT ERROR =================
    if (statusCode >= 400 && statusCode < 500) {
      print(
        'Client error with status code: $statusCode and body: ${response.body}',
      );
      final message =
          decoded?['message']?.toString() ??
          decoded?['error']?.toString() ??
          'Invalid request';
      return Left(ClientFailure(message));
    }

    /// ================= SERVER ERROR =================
    if (statusCode >= 500) {
      print(
        'Server error with status code: $statusCode and body: ${response.body}',
      );
      final message =
          decoded?['message']?.toString() ??
          'Server error. Please try again later.';
      return Left(ServerFailure(message));
    }
    print('sssssssssssssssssssssssssss ${statusCode}');

    /// ================= UNKNOWN =================
    return Left(
      OtherFailureNon200('Unexpected status codesssssss: $statusCode'),
    );
  }

  // ================== Handle Force Logout  handle ==================
  Future<void> _forceLogout() async {
    await localDataSource.clearSession();
    // optional: if you want selective clear
    // 🔥 Navigate globally
    NavigationService.navigateToLogin();
    AppSnackBar.show(
      NavigationService.navigatorKey.currentContext!,
      message: "Session expired. Please log in again.",
      color: Colors.red,
      icon: Icons.error,
      onClosed: () {},
    );
    print("User logged out. Tokens cleared.");
  }

  MediaType getMediaType(String path) {
    final extension = path.split('.').last.toLowerCase();

    switch (extension) {
      /// ================= IMAGE =================
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'bmp':
        return MediaType('image', 'bmp');
      case 'heic':
        return MediaType('image', 'heic');

      /// ================= VIDEO =================
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      case 'avi':
        return MediaType('video', 'x-msvideo');
      case 'mkv':
        return MediaType('video', 'x-matroska');
      case 'webm':
        return MediaType('video', 'webm');
      case '3gp':
        return MediaType('video', '3gpp');

      /// ================= AUDIO =================
      case 'mp3':
        return MediaType('audio', 'mpeg');
      case 'm4a':
        return MediaType('audio', 'm4a');
      case 'aac':
        return MediaType('audio', 'aac');
      case 'wav':
        return MediaType('audio', 'wav');
      case 'ogg':
        return MediaType('audio', 'ogg');
      case 'flac':
        return MediaType('audio', 'flac');

      /// ================= PDF =================
      case 'pdf':
        return MediaType('application', 'pdf');

      /// ================= WORD =================
      case 'doc':
        return MediaType('application', 'msword');
      case 'docx':
        return MediaType(
          'application',
          'vnd.openxmlformats-officedocument.wordprocessingml.document',
        );

      /// ================= EXCEL =================
      case 'xls':
        return MediaType('application', 'vnd.ms-excel');
      case 'xlsx':
        return MediaType(
          'application',
          'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );

      /// ================= POWERPOINT =================
      case 'ppt':
        return MediaType('application', 'vnd.ms-powerpoint');
      case 'pptx':
        return MediaType(
          'application',
          'vnd.openxmlformats-officedocument.presentationml.presentation',
        );

      /// ================= TEXT =================
      case 'txt':
        return MediaType('text', 'plain');
      case 'json':
        return MediaType('application', 'json');
      case 'csv':
        return MediaType('text', 'csv');
      case 'xml':
        return MediaType('application', 'xml');

      /// ================= ARCHIVE =================
      case 'zip':
        return MediaType('application', 'zip');
      case 'rar':
        return MediaType('application', 'vnd.rar');
      case '7z':
        return MediaType('application', 'x-7z-compressed');
      case 'tar':
        return MediaType('application', 'x-tar');

      /// ================= APK =================
      case 'apk':
        return MediaType('application', 'vnd.android.package-archive');

      /// ================= DEFAULT =================
      default:
        return MediaType('application', 'octet-stream');
    }
  }
}
