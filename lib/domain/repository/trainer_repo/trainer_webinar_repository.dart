import 'package:dartz/dartz.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/notification_model/notification_model.dart';
import 'package:lms/data/model/trainer_full_list_webinar_model/trainer_full_list_webinar_model.dart';

abstract class TrainerWebinarRepository {
  Future<Either<Failure, TrainerFullListWebinarModel>> getAllWebinars(
    String? status,
    String? search,
  );
  Future<Either<Failure, NotificationModel>> getAllNotification(String? isRead);
  Future<Either<Failure, Success>> makeIsRead(String? notificationId);
}
