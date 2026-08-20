import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'trainer_resource_upload_model.g.dart';

@JsonSerializable()
class TrainerResourceUploadModel {
  @JsonKey(fromJson: stringFromJson)
  String? statusCode;
  @JsonKey(fromJson: stringFromJson)
  String? success;
  @JsonKey(fromJson: stringFromJson)
  String? message;
  dynamic errorCode;
  Data? data;
  dynamic errors;
  dynamic details;

  TrainerResourceUploadModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory TrainerResourceUploadModel.fromJson(Map<String, dynamic> json) {
    return _$TrainerResourceUploadModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TrainerResourceUploadModelToJson(this);
}

@JsonSerializable()
class Data {
  @JsonKey(fromJson: stringFromJson)
  String? id;
  @JsonKey(fromJson: stringFromJson)
  String? webinarId;

  @JsonKey(fromJson: stringFromJson)
  String? fileName;

  @JsonKey(fromJson: stringFromJson)
  String? fileUrl;

  @JsonKey(fromJson: stringFromJson)
  String? fileType;
  @JsonKey(fromJson: stringFromJson)
  String? fileSize;

  @JsonKey(fromJson: stringFromJson)
  String? uploadedByUserId;

  @JsonKey(fromJson: stringFromJson)
  String? uploadedByUserName;
  @JsonKey(fromJson: stringFromJson)
  String? isVisibleToParticipants;
  @JsonKey(fromJson: stringFromJson)
  String? createdAt;

  Data({
    this.id,
    this.webinarId,
    this.fileName,
    this.fileUrl,
    this.fileType,
    this.fileSize,
    this.uploadedByUserId,
    this.uploadedByUserName,
    this.isVisibleToParticipants,
    this.createdAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
