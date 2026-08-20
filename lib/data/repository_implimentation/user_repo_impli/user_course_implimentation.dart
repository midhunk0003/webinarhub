import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/user_course_detail_model/user_course_detail_model.dart';
import 'package:lms/data/model/user_course_material_list_model/user_course_meterial_list_model.dart';
import 'package:lms/data/model/user_join_webinar_model/user_join_webinar_model.dart';
import 'package:lms/data/model/user_webinar_recordings_model/user_webinar_recordings_model.dart';
import 'package:lms/data/network/api_client.dart';
import 'package:lms/domain/repository/user_repo/user_course_repository.dart';

class UserCourseImplimentation implements UserCourseRepository {
  final ApiClient apiClient;

  UserCourseImplimentation({required this.apiClient});
  @override
  Future<Either<Failure, UserCourseDetailModel>> getUserCourseDetail(
    String? courseId,
  ) async {
    try {
      final response = await apiClient.get(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.trainerCourseDetailEndPoint}/${courseId}",
      );
      log('API get response detail page of course User: $response');
      return response.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final UserCourseDetailData = UserCourseDetailModel.fromJson(data);
          return Right(UserCourseDetailData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserCourseMeterialListModel>> getUserResourceList(
    String? courseId,
  ) async {
    try {
      final response = await apiClient.get(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.trainerGetListOfResourcesEndPoint}/${courseId}",
      );
      log('API get response list of resurce in detail page User: $response');
      return response.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final UserCourseMeterialListData =
              UserCourseMeterialListModel.fromJson(data);
          return Right(UserCourseMeterialListData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserWebinarRecordingsModel>> getUserWebunarRecordings(
    String? courseId,
  ) async {
    try {
      final response = await apiClient.get(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.userWebinarRecordingsEndPoint}/${courseId}",
      );
      log('API get response list of recordings User: $response');
      return response.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final UserWebinarRecordingsData = UserWebinarRecordingsModel.fromJson(
            data,
          );
          return Right(UserWebinarRecordingsData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserJoinWebinarModel>> getUserToJoinWebinar(
    String? courseId,
  ) async {
    try {
      final response = await apiClient.post(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.userJoinWebinarEndPoint}/${courseId}",
      );
      log('API get user join webinardetails: $response');
      return response.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final UserJoinWebinarData = UserJoinWebinarModel.fromJson(data);
          return Right(UserJoinWebinarData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
