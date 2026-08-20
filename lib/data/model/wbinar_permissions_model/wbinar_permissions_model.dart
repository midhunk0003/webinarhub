import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'wbinar_permissions_model.g.dart';

@JsonSerializable()
class WbinarPermissionsModel {
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

  WbinarPermissionsModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory WbinarPermissionsModel.fromJson(Map<String, dynamic> json) {
    return _$WbinarPermissionsModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$WbinarPermissionsModelToJson(this);
}

@JsonSerializable()
class Data {
  @JsonKey(fromJson: stringFromJson)
  String? userId;

  List<String>? roles;

  List<String>? rolePermissions;

  List<String>? grantedOverrides;

  List<String>? deniedOverrides;

  List<String>? effectivePermissions;

  Data({
    this.userId,
    this.roles,
    this.rolePermissions,
    this.grantedOverrides,
    this.deniedOverrides,
    this.effectivePermissions,
  });

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
