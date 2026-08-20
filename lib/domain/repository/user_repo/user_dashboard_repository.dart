import 'package:dartz/dartz.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/trainer_over_view_model/trainer_over_view_model.dart';
import 'package:lms/data/model/trainer_upcomming_and_assigned_model/trainer_upcomming_and_assigned_model.dart';
import 'package:lms/data/model/user_dashboard_upcomming_and_recent_model/user_dashboard_upcomming_and_recent_model.dart';
import 'package:lms/data/model/user_over_view_model/user_over_view_model.dart';

abstract class UserDashboardRepository {
  Future<Either<Failure, UserDashboardUpcommingAndRecentModel>>
  getUserDashboardUpcommAndAssigned();
  Future<Either<Failure, UserOverViewModel>> getUserDashboardOverView();
}
