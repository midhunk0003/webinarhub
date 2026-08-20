import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'trainer_all_webinar_participents_model.g.dart';

@JsonSerializable()
class TrainerAllWebinarParticipentsModel {
  int? statusCode;
  bool? success;
  @JsonKey(fromJson: stringFromJson)
  String? message;
  dynamic errorCode;
  ParticipantData? data;
  dynamic errors;
  dynamic details;

  TrainerAllWebinarParticipentsModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory TrainerAllWebinarParticipentsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return _$TrainerAllWebinarParticipentsModelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$TrainerAllWebinarParticipentsModelToJson(this);
  }
}

@JsonSerializable()
class ParticipantData {
  List<ParticipantItem>? items;
  @JsonKey(fromJson: stringFromJson)
  String? totalCount;

  @JsonKey(fromJson: stringFromJson)
  String? page;

  @JsonKey(fromJson: stringFromJson)
  String? pageSize;

  @JsonKey(fromJson: stringFromJson)
  String? totalPages;

  bool? hasNextPage;

  bool? hasPreviousPage;

  ParticipantData({
    this.items,
    this.totalCount,
    this.page,
    this.pageSize,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  factory ParticipantData.fromJson(Map<String, dynamic> json) =>
      _$ParticipantDataFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipantDataToJson(this);
}

@JsonSerializable()
class ParticipantItem {
  @JsonKey(fromJson: stringFromJson)
  String? id;

  @JsonKey(fromJson: stringFromJson)
  String? webinarId;

  @JsonKey(fromJson: stringFromJson)
  String? userId;

  @JsonKey(fromJson: stringFromJson)
  String? userFullName;

  @JsonKey(fromJson: stringFromJson)
  String? userEmail;

  @JsonKey(fromJson: stringFromJson)
  String? enrollmentStatus;

  @JsonKey(fromJson: stringFromJson)
  String? enrollmentStatusName;

  @JsonKey(fromJson: stringFromJson)
  String? paymentStatus;

  @JsonKey(fromJson: stringFromJson)
  String? paymentStatusName;

  @JsonKey(fromJson: stringFromJson)
  String? enrollmentSource;

  @JsonKey(fromJson: stringFromJson)
  String? enrollmentSourceName;

  @JsonKey(fromJson: stringFromJson)
  String? enrolledByUserId;

  @JsonKey(fromJson: stringFromJson)
  String? enrolledByUserName;
  @JsonKey(fromJson: stringFromJson)
  String? enrollmentDate;

  ParticipantItem({
    this.id,
    this.webinarId,
    this.userId,
    this.userFullName,
    this.userEmail,
    this.enrollmentStatus,
    this.enrollmentStatusName,
    this.paymentStatus,
    this.paymentStatusName,
    this.enrollmentSource,
    this.enrollmentSourceName,
    this.enrolledByUserId,
    this.enrolledByUserName,
    this.enrollmentDate,
  });

  factory ParticipantItem.fromJson(Map<String, dynamic> json) =>
      _$ParticipantItemFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipantItemToJson(this);
}
