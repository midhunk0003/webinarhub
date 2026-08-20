import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/profile_model/profile_model.dart';
import 'package:lms/data/network/api_client.dart';
import 'package:lms/domain/repository/profile_repository.dart';

class ProfileRepoImplimenttation implements ProfileRepository {
  final ApiClient apiClient;

  ProfileRepoImplimenttation({required this.apiClient});
  @override
  Future<Either<Failure, ProfileModel>> getProfileData() async {
    try {
      final result = await apiClient.get(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.profileEndPoint}",
      );

      log('API get Profile Data : $result');
      return result.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final profileData = ProfileModel.fromJson(data);

          return Right(profileData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> updateProfile(
    String? firstMame,
    String? lastName,
    String? mobileNumber,
  ) async {
    print('${firstMame}');
    print('${lastName}');
    print('${mobileNumber}');
    try {
      final result = await apiClient.put(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.updateProfileEndPoint}",
        body: {
          "firstName": firstMame,
          "lastName": lastName,
          "phoneNumber": mobileNumber,
        },
      );

      log('API Update Profile: $result');
      return result.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final profileData = ProfileModel.fromJson(data);

          return Right(
            Success(
              message: profileData.message ?? "Profile updated successfully",
            ),
          );
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
