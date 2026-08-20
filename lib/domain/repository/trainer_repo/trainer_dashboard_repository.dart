import 'package:dartz/dartz.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/trainer_over_view_model/trainer_over_view_model.dart';
import 'package:lms/data/model/trainer_upcomming_and_assigned_model/trainer_upcomming_and_assigned_model.dart';

abstract class TrainerDashboardRepository {
  Future<Either<Failure, TrainerUpcommingAndAssignedModel>>
  getDashboardUpcommAndAssigned();
  Future<Either<Failure, TrainerOverViewModel>> getDashboardOverView();
}
