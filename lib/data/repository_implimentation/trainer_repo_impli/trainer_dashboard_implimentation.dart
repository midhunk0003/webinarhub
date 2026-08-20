import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/trainer_over_view_model/trainer_over_view_model.dart';
import 'package:lms/data/model/trainer_upcomming_and_assigned_model/trainer_upcomming_and_assigned_model.dart';
import 'package:lms/data/network/api_client.dart';
import 'package:lms/domain/repository/trainer_repo/trainer_dashboard_repository.dart';

class TrainerDashboardImplimentation implements TrainerDashboardRepository {
  final ApiClient apiClient;

  TrainerDashboardImplimentation({required this.apiClient});
  @override
  Future<Either<Failure, TrainerUpcommingAndAssignedModel>>
  getDashboardUpcommAndAssigned() async {
    try {
      final response = await apiClient.get(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.trainerDashUpcommingAndAssignedEndPoint}",
      );
      log('API get response dash upcomming and assignes api : $response');
      return response.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final trainerUpcommingAndAssignedData =
              TrainerUpcommingAndAssignedModel.fromJson(data);

          return Right(trainerUpcommingAndAssignedData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TrainerOverViewModel>> getDashboardOverView() async {
    try {
      final response = await apiClient.get(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.trainerDashOverViewEndPoint}",
      );
      log('API get response dash Over View api : $response');
      return response.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final trainerOverViewData = TrainerOverViewModel.fromJson(data);

          return Right(trainerOverViewData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
