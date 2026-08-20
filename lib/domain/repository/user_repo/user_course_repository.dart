import 'package:dartz/dartz.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/data/model/trainer_course_detail_page/trainer_course_detail_page.dart';
import 'package:lms/data/model/trainer_course_meterial_list_model/trainer_course_meterial_list_model.dart';
import 'package:lms/data/model/user_course_detail_model/user_course_detail_model.dart';
import 'package:lms/data/model/user_course_material_list_model/user_course_meterial_list_model.dart';
import 'package:lms/data/model/user_join_webinar_model/user_join_webinar_model.dart';
import 'package:lms/data/model/user_webinar_recordings_model/user_webinar_recordings_model.dart';

abstract class UserCourseRepository {
  Future<Either<Failure, UserCourseDetailModel>> getUserCourseDetail(
    String? courseId,
  );
  Future<Either<Failure, UserCourseMeterialListModel>> getUserResourceList(
    String? courseId,
  );

  Future<Either<Failure, UserWebinarRecordingsModel>> getUserWebunarRecordings(
    String? courseId,
  );

  Future<Either<Failure, UserJoinWebinarModel>> getUserToJoinWebinar(
    String? courseId,
  );
}
