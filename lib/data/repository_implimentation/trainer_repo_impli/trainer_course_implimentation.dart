import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/trainer_all_webinar_participents_model/trainer_all_webinar_participents_model.dart';
import 'package:lms/data/model/trainer_course_detail_page/trainer_course_detail_page.dart';
import 'package:lms/data/model/trainer_course_meterial_list_model/trainer_course_meterial_list_model.dart';
import 'package:lms/data/model/trainer_resource_upload_model/trainer_resource_upload_model.dart';
import 'package:lms/data/network/api_client.dart';
import 'package:lms/domain/repository/trainer_repo/trainer_course_repository.dart';

class TrainerCourseImplimentation implements TrainerCourseRepository {
  final ApiClient apiClient;

  TrainerCourseImplimentation({required this.apiClient});
  @override
  Future<Either<Failure, TrainerCourseDetailModel>> getCourseDetail(
    String? courseId,
  ) async {
    try {
      final response = await apiClient.get(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.trainerCourseDetailEndPoint}/${courseId}",
      );
      log('API get response detail page of course : $response');
      return response.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final trainerCourseDetailData = TrainerCourseDetailModel.fromJson(
            data,
          );
          return Right(trainerCourseDetailData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TrainerCourseMeterialListModel>> getResourceList(
    String? courseId,
  ) async {
    try {
      final response = await apiClient.get(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.trainerGetListOfResourcesEndPoint}/${courseId}",
      );
      log('API get response list of resurce in detail page : $response');
      return response.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final trainerCourseMeterialListData =
              TrainerCourseMeterialListModel.fromJson(data);
          return Right(trainerCourseMeterialListData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TrainerResourceUploadModel>> uploadResource(
    String? courseId,
    String? file,
  ) async {
    try {
      if (courseId == null || courseId.isEmpty) {
        return Left(ClientFailure('Course ID is required'));
      }

      if (file == null || file.isEmpty) {
        return Left(ClientFailure('File is required'));
      }
      final result = await apiClient.post(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.trainerUploadResourcesEndPoint}/${courseId}",
        body: {'course_id': courseId},
        files: {'file': file},
      );
      log('Upload resource response: $result');
      return result.fold(
        (failure) {
          log('Upload resource failure: ${failure.message}');
          return Left(failure);
        },
        (data) {
          final uploadData = TrainerResourceUploadModel.fromJson(data);
          return Right(uploadData);
        },
      );
    } catch (e) {
      log('Upload resource exception: $e');
      return Left(OtherFailureNon200(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> deleteResource(String? resourceId) async {
    try {
      if (resourceId == null || resourceId.isEmpty) {
        return Left(ClientFailure('Resource ID is required'));
      }

      final result = await apiClient.delete(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.trainerdeleteResourcesEndPoint}/$resourceId",
      );

      log('Delete resource response: $result');

      return result.fold(
        (failure) {
          log('Delete resource failure: ${failure.message}');
          return Left(failure);
        },
        (data) {
          log('Delete resource success: $data');

          return Right(
            Success(
              message:
                  data['message']?.toString() ??
                  'Resource deleted successfully',
            ),
          );
        },
      );
    } catch (e) {
      log('Delete resource exception: $e');
      return Left(OtherFailureNon200(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TrainerAllWebinarParticipentsModel>>
  getAllParticipants(String? courseId, String? search) async {
    try {
      final queryParameters = <String, String>{};
      // Add search only when it has a value
      if (search != null && search.isNotEmpty) {
        queryParameters['Search'] = search;
      }

      final uri = Uri.parse(
        '${ApiEndPoint.baseUrl}${ApiEndPoint.webinarParticipantsEndPoint}/${courseId}',
      ).replace(
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      // final response = await apiClient.get(
      //   "${ApiEndPoint.baseUrl}${ApiEndPoint.webinarParticipantsEndPoint}/${courseId}",
      // );

      final response = await apiClient.get(uri.toString());
      log('API get response Participents List : $response');
      return response.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final trainerAllWebinarParticipentsData =
              TrainerAllWebinarParticipentsModel.fromJson(data);
          return Right(trainerAllWebinarParticipentsData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
