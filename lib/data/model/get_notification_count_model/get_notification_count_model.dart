import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'get_notification_count_model.g.dart';

@JsonSerializable()
class GetNotificationCountModel {
  @JsonKey(fromJson: stringFromJson)
  String? statusCode;

  @JsonKey(fromJson: stringFromJson)
  String? success;

  @JsonKey(fromJson: stringFromJson)
  String? message;

  @JsonKey(fromJson: stringFromJson)
  String? errorCode;

  @JsonKey(fromJson: stringFromJson)
  String? data;

  @JsonKey(fromJson: stringFromJson)
  String? errors;

  @JsonKey(fromJson: stringFromJson)
  String? details;

  GetNotificationCountModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory GetNotificationCountModel.fromJson(Map<String, dynamic> json) {
    return _$GetNotificationCountModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$GetNotificationCountModelToJson(this);
}
