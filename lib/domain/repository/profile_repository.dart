import 'package:dartz/dartz.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/get_contact_model/get_contact_model.dart';
import 'package:lms/data/model/help_and_support_model/help_and_support_model.dart';
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
  Future<Either<Failure, Success>> changePassword(
    String? currentPassword,
    String? newPassword,
  );
  Future<Either<Failure, Success>> uploadProfileImage(
    String? profileImage,
    String? userId,
  );

  Future<Either<Failure, GetContactModel>> getContactData();

  Future<Either<Failure, HelpAndSupportModel>> getHelpAndSupport(
    String? search,
    String? CategortId,
  );
}
