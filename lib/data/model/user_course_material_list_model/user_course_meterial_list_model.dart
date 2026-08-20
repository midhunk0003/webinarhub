import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'user_course_meterial_list_model.g.dart';

@JsonSerializable()
class UserCourseMeterialListModel {
  @JsonKey(fromJson: stringFromJson)
  String? statusCode;

  @JsonKey(fromJson: stringFromJson)
  String? success;

  @JsonKey(fromJson: stringFromJson)
  String? message;

  @JsonKey(fromJson: stringFromJson)
  String? errorCode;

  List<UserMaterialData>? data;

  dynamic errors;
  dynamic details;

  UserCourseMeterialListModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory UserCourseMeterialListModel.fromJson(Map<String, dynamic> json) {
    return _$UserCourseMeterialListModelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$UserCourseMeterialListModelToJson(this);
  }
}

@JsonSerializable()
class UserMaterialData {
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

  UserMaterialData({
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

  factory UserMaterialData.fromJson(Map<String, dynamic> json) =>
      _$UserMaterialDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserMaterialDataToJson(this);
}
