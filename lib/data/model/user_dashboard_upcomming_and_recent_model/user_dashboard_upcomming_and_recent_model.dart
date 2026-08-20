import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'user_dashboard_upcomming_and_recent_model.g.dart';

@JsonSerializable()
class UserDashboardUpcommingAndRecentModel {
  @JsonKey(fromJson: stringFromJson)
  String? statusCode;

  @JsonKey(fromJson: stringFromJson)
  String? success;

  @JsonKey(fromJson: stringFromJson)
  String? message;

  @JsonKey(fromJson: stringFromJson)
  String? errorCode;

  UserUpcommingAndAssighData? data;

  dynamic errors;
  dynamic details;

  UserDashboardUpcommingAndRecentModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory UserDashboardUpcommingAndRecentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return _$UserDashboardUpcommingAndRecentModelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$UserDashboardUpcommingAndRecentModelToJson(this);
  }
}

@JsonSerializable()
class UserUpcommingAndAssighData {
  UserUpcomingWebinar? upcomingWebinar;
  List<UserAssignedWebinar>? assignedWebinars;

  UserUpcommingAndAssighData({this.upcomingWebinar, this.assignedWebinars});

  factory UserUpcommingAndAssighData.fromJson(Map<String, dynamic> json) =>
      _$UserUpcommingAndAssighDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserUpcommingAndAssighDataToJson(this);
}

@JsonSerializable()
class UserUpcomingWebinar {
  @JsonKey(fromJson: stringFromJson)
  String? webinarId;

  @JsonKey(fromJson: stringFromJson)
  String? title;

  @JsonKey(fromJson: stringFromJson)
  String? startDate;

  @JsonKey(fromJson: stringFromJson)
  String? endDate;

  @JsonKey(fromJson: stringFromJson)
  String? status;

  @JsonKey(fromJson: stringFromJson)
  String? meetingPlatform;

  @JsonKey(fromJson: stringFromJson)
  String? meetingUrl;

  @JsonKey(fromJson: stringFromJson)
  String? thumbnailUrl;

  @JsonKey(fromJson: stringFromJson)
  String? isPaid;

  @JsonKey(fromJson: stringFromJson)
  String? price;

  UserUpcomingWebinar({
    this.webinarId,
    this.title,
    this.startDate,
    this.endDate,
    this.status,
    this.meetingPlatform,
    this.meetingUrl,
    this.thumbnailUrl,
    this.isPaid,
    this.price,
  });

  factory UserUpcomingWebinar.fromJson(Map<String, dynamic> json) {
    return _$UserUpcomingWebinarFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserUpcomingWebinarToJson(this);
}

@JsonSerializable()
class UserAssignedWebinar {
  @JsonKey(fromJson: stringFromJson)
  String? webinarId;

  @JsonKey(fromJson: stringFromJson)
  String? title;

  @JsonKey(fromJson: stringFromJson)
  String? startDate;

  @JsonKey(fromJson: stringFromJson)
  String? status;

  @JsonKey(fromJson: stringFromJson)
  String? thumbnailUrl;

  @JsonKey(fromJson: stringFromJson)
  String? isPaid;

  @JsonKey(fromJson: stringFromJson)
  String? price;

  UserAssignedWebinar({
    this.webinarId,
    this.title,
    this.startDate,
    this.status,
    this.thumbnailUrl,
    this.isPaid,
    this.price,
  });

  factory UserAssignedWebinar.fromJson(Map<String, dynamic> json) {
    return _$UserAssignedWebinarFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserAssignedWebinarToJson(this);
}
