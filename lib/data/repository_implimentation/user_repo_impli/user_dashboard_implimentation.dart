import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/user_dashboard_upcomming_and_recent_model/user_dashboard_upcomming_and_recent_model.dart';
import 'package:lms/data/model/user_over_view_model/user_over_view_model.dart';
import 'package:lms/data/network/api_client.dart';
import 'package:lms/domain/repository/user_repo/user_dashboard_repository.dart';

class UserDashboardImplimentation implements UserDashboardRepository {
  final ApiClient apiClient;

  UserDashboardImplimentation({required this.apiClient});

  @override
  Future<Either<Failure, UserOverViewModel>> getUserDashboardOverView() async {
    try {
      final response = await apiClient.get(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.UserDashOverViewEndPoint}",
      );
      log('API get response User dash Over View api : $response');
      return response.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final userOverViewData = UserOverViewModel.fromJson(data);

          return Right(userOverViewData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserDashboardUpcommingAndRecentModel>>
  getUserDashboardUpcommAndAssigned() async {
    try {
      final response = await apiClient.get(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.userDashUpcommingAndAssignedEndPoint}",
      );
      log('API get response User dash upcomming and assignes api : $response');
      return response.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final userDashboardUpcommingAndRecentData =
              UserDashboardUpcommingAndRecentModel.fromJson(data);

          return Right(userDashboardUpcommingAndRecentData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
