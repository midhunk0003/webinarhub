import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/user_full_list_webinar_model/user_full_list_webinar_model.dart';
import 'package:lms/data/network/api_client.dart';
import 'package:lms/domain/repository/user_repo/user_webinar_repository.dart';

class UserAllWebinarImplimentation implements UserWebinarRepository {
  final ApiClient apiClient;

  UserAllWebinarImplimentation({required this.apiClient});
  @override
  Future<Either<Failure, UserFullListWebinarModel>> getAllUserWebinars(
    String? status,
    String? search,
  ) async {
    try {
      final queryParameters = <String, String>{};
      // Add status only when it has a value
      if (status != null && status.isNotEmpty) {
        queryParameters['TimeFilter'] = status;
      }

      // Add search only when it has a value
      if (search != null && search.isNotEmpty) {
        queryParameters['Search'] = search;
      }

      final uri = Uri.parse(
        '${ApiEndPoint.baseUrl}${ApiEndPoint.userAllWebinarEndPoint}',
      ).replace(
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      log('GET WEBINARS URL: $uri');

      final response = await apiClient.get(uri.toString());

      log('API get response all User webinar list api : $response');
      return response.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final userFullListWebinarData = UserFullListWebinarModel.fromJson(
            data,
          );

          return Right(userFullListWebinarData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
