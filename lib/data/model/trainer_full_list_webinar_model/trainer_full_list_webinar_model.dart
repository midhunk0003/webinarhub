import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'trainer_full_list_webinar_model.g.dart';

@JsonSerializable()
class TrainerFullListWebinarModel {
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

  TrainerFullListWebinarModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory TrainerFullListWebinarModel.fromJson(Map<String, dynamic> json) {
    return _$TrainerFullListWebinarModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TrainerFullListWebinarModelToJson(this);
}

@JsonSerializable()
class Data {
  List<Item>? items;

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

  Data({
    this.items,
    this.totalCount,
    this.page,
    this.pageSize,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}

@JsonSerializable()
class Item {
  @JsonKey(fromJson: stringFromJson)
  String? id;

  @JsonKey(fromJson: stringFromJson)
  String? title;

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
  String? platform;

  @JsonKey(fromJson: stringFromJson)
  String? platformName;

  @JsonKey(fromJson: stringFromJson)
  String? trainerId;

  @JsonKey(fromJson: stringFromJson)
  String? trainerName;

  @JsonKey(fromJson: stringFromJson)
  String? isPaid;

  @JsonKey(fromJson: stringFromJson)
  String? price;

  @JsonKey(fromJson: stringFromJson)
  String? maxParticipants;

  @JsonKey(fromJson: stringFromJson)
  String? enrolledParticipantCount;

  @JsonKey(fromJson: stringFromJson)
  String? createdAt;

  Item({
    this.id,
    this.title,
    this.category,
    this.thumbnailUrl,
    this.startDateTime,
    this.endDateTime,
    this.status,
    this.statusName,
    this.platform,
    this.platformName,
    this.trainerId,
    this.trainerName,
    this.isPaid,
    this.price,
    this.maxParticipants,
    this.enrolledParticipantCount,
    this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
