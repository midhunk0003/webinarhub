import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/wbinar_permissions_model/wbinar_permissions_model.dart';
import 'package:lms/data/network/api_client.dart';
import 'package:lms/domain/repository/permission_repository.dart';

class PermissionRepoImplimentation implements PermissionRepository {
  final ApiClient apiClient;

  PermissionRepoImplimentation({required this.apiClient});

  @override
  Future<Either<Failure, WbinarPermissionsModel>> getPermisionData(
    String? userId,
  ) async {
    try {
      final result = await apiClient.get(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.permissionEndPoint}/${userId}",
      );

      log('API get Permission Data List : $result');
      return result.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final wbinarPermissionsData = WbinarPermissionsModel.fromJson(data);

          return Right(wbinarPermissionsData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
