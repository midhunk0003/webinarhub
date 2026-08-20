import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  @JsonKey(fromJson: stringFromJson)
  String? statusCode;

  @JsonKey(fromJson: stringFromJson)
  String? success;

  @JsonKey(fromJson: stringFromJson)
  String? message;

  @JsonKey(fromJson: stringFromJson)
  String? errorCode;

  NotificationData? data;

  @JsonKey(fromJson: stringFromJson)
  String? errors;

  @JsonKey(fromJson: stringFromJson)
  String? details;

  NotificationModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return _$NotificationModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}

@JsonSerializable()
class NotificationData {
  List<NotificationItem>? items;

  @JsonKey(fromJson: stringFromJson)
  String? totalCount;

  @JsonKey(fromJson: stringFromJson)
  String? page;

  @JsonKey(fromJson: stringFromJson)
  String? pageSize;

  @JsonKey(fromJson: stringFromJson)
  String? totalPages;

  @JsonKey(fromJson: stringFromJson)
  String? hasNextPage;

  @JsonKey(fromJson: stringFromJson)
  String? hasPreviousPage;

  NotificationData({
    this.items,
    this.totalCount,
    this.page,
    this.pageSize,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return _$NotificationDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$NotificationDataToJson(this);
}

@JsonSerializable()
class NotificationItem {
  @JsonKey(fromJson: stringFromJson)
  String? id;

  @JsonKey(fromJson: stringFromJson)
  String? title;

  @JsonKey(fromJson: stringFromJson)
  String? message;

  @JsonKey(fromJson: stringFromJson)
  String? event;

  @JsonKey(fromJson: stringFromJson)
  String? isRead;

  @JsonKey(fromJson: stringFromJson)
  String? createdAt;

  NotificationItem({
    this.id,
    this.title,
    this.message,
    this.event,
    this.isRead,
    this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return _$NotificationItemFromJson(json);
  }

  Map<String, dynamic> toJson() => _$NotificationItemToJson(this);
}
