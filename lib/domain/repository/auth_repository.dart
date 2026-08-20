import 'package:dartz/dartz.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/login_model/login_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginModel>> Login(
    String? email,
    String? password,
    String? fcmToken,
  );
  Future<Either<Failure, LoginModel>> Register(
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
  );
}
