import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/user_dashboard_upcomming_and_recent_model/user_dashboard_upcomming_and_recent_model.dart';
import 'package:lms/data/model/user_over_view_model/user_over_view_model.dart';
import 'package:lms/data/model/user_policy_and_agree_model/user_policy_and_agree_model.dart';
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

  @override
  Future<Either<Failure, UserPolicyAndAgreeModel>>
  getUserPolicyAndAgree() async {
    try {
      final response = await apiClient.get(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.userPolicyEndPoint}",
      );
      log('API get response Userprivacy and policy api : $response');
      return response.fold(
        (failure) {
          print("failure inside repoimpli: ${failure.message}");
          return Left(failure);
        },
        (data) async {
          final UserPolicyAndAgreeData = UserPolicyAndAgreeModel.fromJson(data);

          return Right(UserPolicyAndAgreeData);
        },
      );
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> acceptPolicy(List<int> policyIds) async {
    try {
      if (policyIds.isEmpty) {
        return Left(ClientFailure('At least one policy ID is required'));
      }

      final result = await apiClient.post(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.userPolicyAcceptEndPoint}",
        body: {'policyIds': policyIds},
      );

      log('Accept policy response: $result');

      return result.fold(
        (failure) {
          log('Accept policy failure: ${failure.message}');

          return Left(failure);
        },
        (data) {
          log('Accept policy success: $data');

          return Right(
            Success(
              message:
                  data is Map
                      ? data['message']?.toString() ??
                          'Policy accepted successfully'
                      : 'Policy accepted successfully',
            ),
          );
        },
      );
    } catch (e) {
      log('Accept policy exception: $e');

      return Left(OtherFailureNon200('Unable to accept privacy policy: $e'));
    }
  }
}
