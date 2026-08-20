import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'user_join_webinar_model.g.dart';

@JsonSerializable()
class UserJoinWebinarModel {
  int? statusCode;
  bool? success;

  @JsonKey(fromJson: stringFromJson)
  String? message;

  @JsonKey(fromJson: stringFromJson)
  String? errorCode;

  JoinData? data;
  Errors? errors;

  @JsonKey(fromJson: stringFromJson)
  String? details;

  UserJoinWebinarModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory UserJoinWebinarModel.fromJson(Map<String, dynamic> json) {
    return _$UserJoinWebinarModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserJoinWebinarModelToJson(this);
}

@JsonSerializable()
class Errors {
  List<String>? additionalProp1;
  List<String>? additionalProp2;
  List<String>? additionalProp3;

  Errors({this.additionalProp1, this.additionalProp2, this.additionalProp3});

  factory Errors.fromJson(Map<String, dynamic> json) {
    return _$ErrorsFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ErrorsToJson(this);
}

@JsonSerializable()
class JoinData {
  @JsonKey(fromJson: stringFromJson)
  String? meetingUrl;

  @JsonKey(fromJson: stringFromJson)
  String? meetingId;

  @JsonKey(fromJson: stringFromJson)
  String? meetingPassword;

  JoinData({this.meetingUrl, this.meetingId, this.meetingPassword});

  factory JoinData.fromJson(Map<String, dynamic> json) {
    return _$JoinDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$JoinDataToJson(this);
}
