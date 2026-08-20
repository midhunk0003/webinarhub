import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'trainer_course_detail_page.g.dart';

@JsonSerializable()
class TrainerCourseDetailModel {
  @JsonKey(fromJson: stringFromJson)
  String? statusCode;

  @JsonKey(fromJson: stringFromJson)
  String? success;
  @JsonKey(fromJson: stringFromJson)
  String? message;

  @JsonKey(fromJson: stringFromJson)
  String? errorCode;

  Data? data;

  @JsonKey(fromJson: stringFromJson)
  String? errors;

  @JsonKey(fromJson: stringFromJson)
  String? details;

  TrainerCourseDetailModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory TrainerCourseDetailModel.fromJson(Map<String, dynamic> json) {
    return _$TrainerCourseDetailModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TrainerCourseDetailModelToJson(this);
}

@JsonSerializable()
class Data {
  @JsonKey(fromJson: stringFromJson)
  String? id;
  @JsonKey(fromJson: stringFromJson)
  String? title;
  @JsonKey(fromJson: stringFromJson)
  String? description;
  @JsonKey(fromJson: stringFromJson)
  String? category;

  @JsonKey(fromJson: stringFromJson)
  String? thumbnailUrl;

  @JsonKey(fromJson: stringFromJson)
  String? startDateTime;

  @JsonKey(fromJson: stringFromJson)
  String? endDateTime;

  @JsonKey(fromJson: stringFromJson)
  String? status;
  @JsonKey(fromJson: stringFromJson)
  String? statusName;

  @JsonKey(fromJson: stringFromJson)
  String? platform;
  @JsonKey(fromJson: stringFromJson)
  String? language;
  @JsonKey(fromJson: stringFromJson)
  String? type;
  @JsonKey(fromJson: stringFromJson)
  String? typeName;
  @JsonKey(fromJson: stringFromJson)
  String? platformName;
  @JsonKey(fromJson: stringFromJson)
  String? meetingLink;
  @JsonKey(fromJson: stringFromJson)
  String? meetingId;

  @JsonKey(fromJson: stringFromJson)
  String? maxParticipants;

  @JsonKey(fromJson: stringFromJson)
  String? isPaid;

  @JsonKey(fromJson: stringFromJson)
  String? price;
  @JsonKey(fromJson: stringFromJson)
  String? trainerId;
  @JsonKey(fromJson: stringFromJson)
  String? trainerName;
  @JsonKey(fromJson: stringFromJson)
  String? trainerEmail;
  @JsonKey(fromJson: stringFromJson)
  String? enrolledParticipantCount;
  @JsonKey(fromJson: stringFromJson)
  String? pendingParticipantCount;

  @JsonKey(fromJson: stringFromJson)
  String? materialCount;

  @JsonKey(fromJson: stringFromJson)
  String? recordingCount;

  @JsonKey(fromJson: stringFromJson)
  String? createdAt;

  @JsonKey(fromJson: stringFromJson)
  String? updatedAt;

  Data({
    this.id,
    this.title,
    this.description,
    this.category,
    this.thumbnailUrl,
    this.startDateTime,
    this.endDateTime,
    this.status,
    this.statusName,
    this.platform,
    this.language,
    this.type,
    this.typeName,
    this.platformName,
    this.meetingLink,
    this.meetingId,
    this.maxParticipants,
    this.isPaid,
    this.price,
    this.trainerId,
    this.trainerName,
    this.trainerEmail,
    this.enrolledParticipantCount,
    this.pendingParticipantCount,
    this.materialCount,
    this.recordingCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
