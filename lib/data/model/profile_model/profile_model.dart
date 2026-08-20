import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel {
  int? statusCode;
  bool? success;

  @JsonKey(fromJson: stringFromJson)
  String? message;

  @JsonKey(fromJson: stringFromJson)
  String? errorCode;

  ProfileData? data;
  Errors? errors;

  @JsonKey(fromJson: stringFromJson)
  String? details;

  ProfileModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}

@JsonSerializable()
class ProfileData {
  @JsonKey(fromJson: stringFromJson)
  String? userId;

  @JsonKey(fromJson: stringFromJson)
  String? email;

  @JsonKey(fromJson: stringFromJson)
  String? username;

  @JsonKey(fromJson: stringFromJson)
  String? firstName;

  @JsonKey(fromJson: stringFromJson)
  String? lastName;

  @JsonKey(fromJson: stringFromJson)
  String? fullName;

  @JsonKey(fromJson: stringFromJson)
  String? phoneNumber;

  @JsonKey(fromJson: stringFromJson)
  String? profileImageUrl;

  @JsonKey(fromJson: stringFromJson)
  String? status;

  @JsonKey(fromJson: stringFromJson)
  String? role;

  @JsonKey(fromJson: stringFromJson)
  String? isEmailConfirmed;

  @JsonKey(fromJson: stringFromJson)
  String? createdAt;

  @JsonKey(fromJson: stringFromJson)
  String? lastLoginAt;

  ProfileData({
    this.userId,
    this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.fullName,
    this.phoneNumber,
    this.profileImageUrl,
    this.status,
    this.role,
    this.isEmailConfirmed,
    this.createdAt,
    this.lastLoginAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) =>
      _$ProfileDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDataToJson(this);
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
