import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'user_over_view_model.g.dart';

@JsonSerializable()
class UserOverViewModel {
  @JsonKey(fromJson: stringFromJson)
  String? statusCode;

  @JsonKey(fromJson: stringFromJson)
  String? success;

  @JsonKey(fromJson: stringFromJson)
  String? message;

  @JsonKey(fromJson: stringFromJson)
  String? errorCode;

  Data? data;

  dynamic errors;
  dynamic details;

  UserOverViewModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory UserOverViewModel.fromJson(Map<String, dynamic> json) {
    return _$UserOverViewModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserOverViewModelToJson(this);
}

@JsonSerializable()
class Data {
  @JsonKey(fromJson: stringFromJson)
  String? upcomingWebinarsCount;

  @JsonKey(fromJson: stringFromJson)
  String? pastWebinarsCount;

  @JsonKey(fromJson: stringFromJson)
  String? totalMaterialsAvailable;

  @JsonKey(fromJson: stringFromJson)
  String? unreadNotificationsCount;

  @JsonKey(fromJson: stringFromJson)
  String? totalSuccessfulPayments;

  @JsonKey(fromJson: stringFromJson)
  String? totalAmountSpent;

  Data({
    this.upcomingWebinarsCount,
    this.pastWebinarsCount,
    this.totalMaterialsAvailable,
    this.unreadNotificationsCount,
    this.totalSuccessfulPayments,
    this.totalAmountSpent,
  });

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
