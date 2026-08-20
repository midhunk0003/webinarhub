import 'package:dartz/dartz.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/login_model/login_model.dart';
import 'package:lms/data/model/wbinar_permissions_model/wbinar_permissions_model.dart';

abstract class PermissionRepository {
  Future<Either<Failure, WbinarPermissionsModel>> getPermisionData(
    String? userId,
  );
}
