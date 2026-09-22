import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'user_policy_and_agree_model.g.dart';

@JsonSerializable()
class UserPolicyAndAgreeModel {
  @JsonKey(fromJson: stringFromJson)
  String? statusCode;

  @JsonKey(fromJson: stringFromJson)
  String? success;

  @JsonKey(fromJson: stringFromJson)
  String? message;

  @JsonKey(fromJson: stringFromJson)
  String? errorCode;

  List<PolicyAndAgreeList>? data;

  Errors? errors;

  @JsonKey(fromJson: stringFromJson)
  String? details;

  UserPolicyAndAgreeModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory UserPolicyAndAgreeModel.fromJson(Map<String, dynamic> json) {
    return _$UserPolicyAndAgreeModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserPolicyAndAgreeModelToJson(this);
}

@JsonSerializable()
class PolicyAndAgreeList {
  @JsonKey(fromJson: stringFromJson)
  String? id;

  @JsonKey(fromJson: stringFromJson)
  String? type;

  @JsonKey(fromJson: stringFromJson)
  String? key;

  @JsonKey(fromJson: stringFromJson)
  String? title;

  @JsonKey(fromJson: stringFromJson)
  String? content;

  @JsonKey(fromJson: stringFromJson)
  String? version;

  @JsonKey(fromJson: stringFromJson)
  String? isRequired;

  @JsonKey(fromJson: stringFromJson)
  String? isActive;

  @JsonKey(fromJson: stringFromJson)
  String? effectiveFrom;

  PolicyAndAgreeList({
    this.id,
    this.type,
    this.key,
    this.title,
    this.content,
    this.version,
    this.isRequired,
    this.isActive,
    this.effectiveFrom,
  });

  factory PolicyAndAgreeList.fromJson(Map<String, dynamic> json) =>
      _$PolicyAndAgreeListFromJson(json);

  Map<String, dynamic> toJson() => _$PolicyAndAgreeListToJson(this);
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
