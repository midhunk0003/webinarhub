import 'package:dartz/dartz.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/login_model/login_model.dart';
import 'package:lms/data/model/profile_model/profile_model.dart';
import 'package:lms/data/model/wbinar_permissions_model/wbinar_permissions_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileModel>> getProfileData();
  Future<Either<Failure, Success>> updateProfile(
    String? firstMame,
    String? lastName,
    String? mobileNumber,
  );
}
