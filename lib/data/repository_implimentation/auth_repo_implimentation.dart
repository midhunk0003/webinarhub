import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/local_data_source/local_data_sourse.dart';
import 'package:lms/data/model/login_model/login_model.dart';
import 'package:lms/data/network/api_client.dart';
import 'package:lms/domain/repository/auth_repository.dart';

class AuthRepositoryImplimentation implements AuthRepository {
  final ApiClient apiClient;
  final AuthLocalDataSource localDataSource;
  AuthRepositoryImplimentation({
    required this.apiClient,
    required this.localDataSource,
  });
  @override
  Future<Either<Failure, LoginModel>> Login(
    String? email,
    String? password,
    String? fcmToken,
  ) async {
    try {
      final response = await apiClient.post(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.loginEndPoint}",
        body: {"email": email, "password": password, 'fcmToken': fcmToken},
        requiresAuth: false,
        files: null,
      );
      log('API get responsefor auth: $response');
      return response.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final loginModel = LoginModel.fromJson(data);

          /// SAVE USER DATA
          await localDataSource.saveUserData(loginModel);
          return Right(loginModel);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoginModel>> Register(
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
  ) async {
    try {
      final response = await apiClient.post(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.registerEndPoint}",
        body: {
          "name": name,
          "email": email,
          "password": password,
          "password_confirmation": confirmPassword,
        },
        requiresAuth: false,
      );
      log('API get response for auth Register: $response');
      return response.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          // same model for  register and login response
          final loginModel = LoginModel.fromJson(data);

          /// SAVE Register USER DATA
          await localDataSource.saveUserData(loginModel);
          return Right(loginModel);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
