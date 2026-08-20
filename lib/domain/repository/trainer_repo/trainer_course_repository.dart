import 'package:dartz/dartz.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/trainer_all_webinar_participents_model/trainer_all_webinar_participents_model.dart';
import 'package:lms/data/model/trainer_course_detail_page/trainer_course_detail_page.dart';
import 'package:lms/data/model/trainer_course_meterial_list_model/trainer_course_meterial_list_model.dart';
import 'package:lms/data/model/trainer_resource_upload_model/trainer_resource_upload_model.dart';

abstract class TrainerCourseRepository {
  Future<Either<Failure, TrainerCourseDetailModel>> getCourseDetail(
    String? courseId,
  );
  Future<Either<Failure, TrainerCourseMeterialListModel>> getResourceList(
    String? courseId,
  );

  Future<Either<Failure, TrainerResourceUploadModel>> uploadResource(
    String? courseId,
    String? file,
  );

  Future<Either<Failure, Success>> deleteResource(String? resourceId);

  Future<Either<Failure, TrainerAllWebinarParticipentsModel>>
  getAllParticipants(String? courseId, String? Search);
}
