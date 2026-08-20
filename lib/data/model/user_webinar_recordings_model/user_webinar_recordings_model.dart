import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'user_webinar_recordings_model.g.dart';

@JsonSerializable()
class UserWebinarRecordingsModel {
  int? statusCode;
  bool? success;

  @JsonKey(fromJson: stringFromJson)
  String? message;

  @JsonKey(fromJson: stringFromJson)
  String? errorCode;

  List<WebinarRecordinsData>? data;

  Errors? errors;

  @JsonKey(fromJson: stringFromJson)
  String? details;

  UserWebinarRecordingsModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory UserWebinarRecordingsModel.fromJson(Map<String, dynamic> json) =>
      _$UserWebinarRecordingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserWebinarRecordingsModelToJson(this);
}

@JsonSerializable()
class WebinarRecordinsData {
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

  WebinarRecordinsData({
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

  factory WebinarRecordinsData.fromJson(Map<String, dynamic> json) =>
      _$WebinarRecordinsDataFromJson(json);

  Map<String, dynamic> toJson() => _$WebinarRecordinsDataToJson(this);
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
