import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'login_model.g.dart';

@JsonSerializable()
class LoginModel {
  int? statusCode;
  bool? success;

  @JsonKey(fromJson: stringFromJson)
  String? message;

  Data? data;
  dynamic errors;
  dynamic details;

  LoginModel({
    this.statusCode,
    this.success,
    this.message,
    this.data,
    this.errors,
    this.details,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginModelToJson(this);
}

@JsonSerializable()
class Data {
  @JsonKey(fromJson: stringFromJson)
  String? accessToken;

  @JsonKey(fromJson: stringFromJson)
  String? refreshToken;

  @JsonKey(fromJson: stringFromJson)
  String? accessTokenExpiry;

  User? user;

  Data({
    this.accessToken,
    this.refreshToken,
    this.accessTokenExpiry,
    this.user,
  });

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}

@JsonSerializable()
class User {
  @JsonKey(fromJson: stringFromJson)
  String? userId;

  @JsonKey(fromJson: stringFromJson)
  String? email;

  @JsonKey(fromJson: stringFromJson)
  String? username;

  @JsonKey(fromJson: stringFromJson)
  String? fullName;

  @JsonKey(fromJson: stringFromJson)
  String? status;

  @JsonKey(fromJson: stringFromJson)
  String? role;

  @JsonKey(fromJson: stringFromJson)
  String? mustChangePassword;

  @JsonKey(fromJson: stringFromJson)
  String? lastLoginAt;

  User({
    this.userId,
    this.email,
    this.username,
    this.fullName,
    this.status,
    this.role,
    this.mustChangePassword,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
