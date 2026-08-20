import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'user_full_list_webinar_model.g.dart';

@JsonSerializable()
class UserFullListWebinarModel {
  @JsonKey(fromJson: stringFromJson)
  String? statusCode;

  @JsonKey(fromJson: stringFromJson)
  String? success;

  @JsonKey(fromJson: stringFromJson)
  String? message;

  @JsonKey(fromJson: stringFromJson)
  String? errorCode;

  AllWebinarData? data;

  @JsonKey(fromJson: stringFromJson)
  String? errors;

  @JsonKey(fromJson: stringFromJson)
  String? details;

  UserFullListWebinarModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory UserFullListWebinarModel.fromJson(Map<String, dynamic> json) =>
      _$UserFullListWebinarModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserFullListWebinarModelToJson(this);
}

@JsonSerializable()
class AllWebinarData {
  List<AllWebinarItem>? items;

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

  AllWebinarData({
    this.items,
    this.totalCount,
    this.page,
    this.pageSize,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  factory AllWebinarData.fromJson(Map<String, dynamic> json) =>
      _$AllWebinarDataFromJson(json);

  Map<String, dynamic> toJson() => _$AllWebinarDataToJson(this);
}

@JsonSerializable()
class AllWebinarItem {
  @JsonKey(fromJson: stringFromJson)
  String? id;

  @JsonKey(fromJson: stringFromJson)
  String? title;

  @JsonKey(fromJson: stringFromJson)
  String? description;

  @JsonKey(fromJson: stringFromJson)
  String? category;

  @JsonKey(fromJson: stringFromJson)
  String? thumbnailUrl;

  @JsonKey(fromJson: stringFromJson)
  String? startDateTime;

  @JsonKey(fromJson: stringFromJson)
  String? endDateTime;

  @JsonKey(fromJson: stringFromJson)
  String? status;

  @JsonKey(fromJson: stringFromJson)
  String? statusName;

  @JsonKey(fromJson: stringFromJson)
  String? trainerName;

  @JsonKey(fromJson: stringFromJson)
  String? isPaid;

  @JsonKey(fromJson: stringFromJson)
  String? price;

  @JsonKey(fromJson: stringFromJson)
  String? paymentStatus;

  @JsonKey(fromJson: stringFromJson)
  String? platform;

  @JsonKey(fromJson: stringFromJson)
  String? paymentStatusName;

  @JsonKey(fromJson: stringFromJson)
  String? platformName;

  @JsonKey(fromJson: stringFromJson)
  String? enrollmentStatus;

  @JsonKey(fromJson: stringFromJson)
  String? enrollmentStatusName;

  @JsonKey(fromJson: stringFromJson)
  String? canJoin;

  AllWebinarItem({
    this.id,
    this.title,
    this.description,
    this.category,
    this.thumbnailUrl,
    this.startDateTime,
    this.endDateTime,
    this.status,
    this.statusName,
    this.trainerName,
    this.isPaid,
    this.price,
    this.paymentStatus,
    this.platform,
    this.paymentStatusName,
    this.platformName,
    this.enrollmentStatus,
    this.enrollmentStatusName,
    this.canJoin,
  });

  factory AllWebinarItem.fromJson(Map<String, dynamic> json) =>
      _$AllWebinarItemFromJson(json);

  Map<String, dynamic> toJson() => _$AllWebinarItemToJson(this);
}
