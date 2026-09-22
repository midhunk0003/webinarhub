import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'trainer_webinar_recordings_model.g.dart';

@JsonSerializable()
class TrainerWebinarRecordingsModel {
  int? statusCode;
  bool? success;

  @JsonKey(fromJson: stringFromJson)
  String? message;

  @JsonKey(fromJson: stringFromJson)
  String? errorCode;

  List<TrainerWebinarRecordinsData>? data;

  Errors? errors;

  @JsonKey(fromJson: stringFromJson)
  String? details;

  TrainerWebinarRecordingsModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory TrainerWebinarRecordingsModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerWebinarRecordingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrainerWebinarRecordingsModelToJson(this);
}

@JsonSerializable()
class TrainerWebinarRecordinsData {
  int? id;
  int? webinarId;

  @JsonKey(fromJson: stringFromJson)
  String? title;

  @JsonKey(fromJson: stringFromJson)
  String? recordingUrl;

  @JsonKey(fromJson: stringFromJson)
  String? duration;

  @JsonKey(fromJson: stringFromJson)
  String? uploadedByUserId;

  @JsonKey(fromJson: stringFromJson)
  String? uploadedByUserName;

  bool? isVisibleToParticipants;

  DateTime? createdAt;

  TrainerWebinarRecordinsData({
    this.id,
    this.webinarId,
    this.title,
    this.recordingUrl,
    this.duration,
    this.uploadedByUserId,
    this.uploadedByUserName,
    this.isVisibleToParticipants,
    this.createdAt,
  });

  factory TrainerWebinarRecordinsData.fromJson(Map<String, dynamic> json) =>
      _$TrainerWebinarRecordinsDataFromJson(json);

  Map<String, dynamic> toJson() => _$TrainerWebinarRecordinsDataToJson(this);
}

@JsonSerializable()
class Errors {
  List<String>? additionalProp1;
  List<String>? additionalProp2;
  List<String>? additionalProp3;

  Errors({this.additionalProp1, this.additionalProp2, this.additionalProp3});

  factory Errors.fromJson(Map<String, dynamic> json) => _$ErrorsFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorsToJson(this);
}
