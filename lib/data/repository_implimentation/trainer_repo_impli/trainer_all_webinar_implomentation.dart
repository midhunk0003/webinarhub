import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/notification_model/notification_model.dart';
import 'package:lms/data/model/trainer_full_list_webinar_model/trainer_full_list_webinar_model.dart';
import 'package:lms/data/model/trainer_over_view_model/trainer_over_view_model.dart';
import 'package:lms/data/model/trainer_upcomming_and_assigned_model/trainer_upcomming_and_assigned_model.dart';
import 'package:lms/data/network/api_client.dart';
import 'package:lms/domain/repository/trainer_repo/trainer_webinar_repository.dart';

class TrainerAllWebinarImplomentation implements TrainerWebinarRepository {
  final ApiClient apiClient;

  TrainerAllWebinarImplomentation({required this.apiClient});

  @override
  Future<Either<Failure, TrainerFullListWebinarModel>> getAllWebinars(
    String? status,
    String? search,
  ) async {
    try {
      final queryParameters = <String, String>{};
      // Add status only when it has a value
      if (status != null && status.isNotEmpty) {
        queryParameters['Status'] = status;
      }

      // Add search only when it has a value
      if (search != null && search.isNotEmpty) {
        queryParameters['Search'] = search;
      }

      final uri = Uri.parse(
        '${ApiEndPoint.baseUrl}${ApiEndPoint.traineAllWebinarEndPoint}',
      ).replace(
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      log('GET WEBINARS URL: $uri');

      final response = await apiClient.get(uri.toString());

      log('API get response all webinar list api : $response');
      return response.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final trainerFullListWebinarData =
              TrainerFullListWebinarModel.fromJson(data);

          return Right(trainerFullListWebinarData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationModel>> getAllNotification(
    String? isRead,
  ) async {
    try {
      final queryParameters = <String, String>{};

      // Add Status only when it has a value
      if (isRead != null) {
        queryParameters['IsRead'] = isRead.toString();
      }

      final uri = Uri.parse(
        '${ApiEndPoint.baseUrl}${ApiEndPoint.notificationEndPoint}',
      ).replace(
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      log('GET NOTIFICATIONS URL: $uri');

      final response = await apiClient.get(uri.toString());

      log('API get response notification list: $response');

      return response.fold(
        (failure) {
          log('Failure inside notification repository: ${failure.message}');

          return Left(failure);
        },
        (data) {
          final notificationModel = NotificationModel.fromJson(data);

          return Right(notificationModel);
        },
      );
    } catch (e) {
      log('Exception in getAllNotification: $e');

      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> makeIsRead(String? notificationId) async {
    try {
      if (notificationId == null || notificationId.isEmpty) {
        return Left(ClientFailure('Notification ID is required'));
      }

      final result = await apiClient.patch(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.NotificationsReadEndPoint}/$notificationId",
      );

      log('Mark notification as read response: $result');

      return result.fold(
        (failure) {
          log('Mark notification as read failure: ${failure.message}');
          return Left(failure);
        },
        (data) {
          log('Mark notification as read success: $data');

          return Right(
            Success(
              message:
                  data['message']?.toString() ??
                  'Notification marked as read successfully',
            ),
          );
        },
      );
    } catch (e) {
      log('Mark notification as read exception: $e');
      return Left(OtherFailureNon200(e.toString()));
    }
  }
}
