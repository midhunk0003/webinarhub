import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'trainer_upcomming_and_assigned_model.g.dart';

@JsonSerializable()
class TrainerUpcommingAndAssignedModel {
  int? statusCode;
  bool? success;
  @JsonKey(fromJson: stringFromJson)
  String? message;
  Data? data;
  dynamic errors;
  dynamic details;

  TrainerUpcommingAndAssignedModel({
    this.statusCode,
    this.success,
    this.message,
    this.data,
    this.errors,
    this.details,
  });

  factory TrainerUpcommingAndAssignedModel.fromJson(Map<String, dynamic> json) {
    return _$TrainerUpcommingAndAssignedModelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$TrainerUpcommingAndAssignedModelToJson(this);
  }
}

@JsonSerializable()
class Data {
  UpcomingWebinar? upcomingWebinar;
  List<AssignedWebinar>? assignedWebinars;

  Data({this.upcomingWebinar, this.assignedWebinars});

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}

@JsonSerializable()
class UpcomingWebinar {
  @JsonKey(fromJson: stringFromJson)
  String? id;
  @JsonKey(fromJson: stringFromJson)
  String? title;
  @JsonKey(fromJson: stringFromJson)
  String? startDateTime;
  @JsonKey(fromJson: stringFromJson)
  String? endDateTime;
  @JsonKey(fromJson: stringFromJson)
  String? thumbnailUrl;
  @JsonKey(fromJson: stringFromJson)
  String? status;
  @JsonKey(fromJson: stringFromJson)
  String? enrolledCount;
  @JsonKey(fromJson: stringFromJson)
  String? platform;
  @JsonKey(fromJson: stringFromJson)
  String? meetingUrl;

  UpcomingWebinar({
    this.id,
    this.title,
    this.startDateTime,
    this.endDateTime,
    this.thumbnailUrl,
    this.status,
    this.enrolledCount,
    this.platform,
    this.meetingUrl,
  });

  factory UpcomingWebinar.fromJson(Map<String, dynamic> json) {
    return _$UpcomingWebinarFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UpcomingWebinarToJson(this);
}

@JsonSerializable()
class AssignedWebinar {
  @JsonKey(fromJson: stringFromJson)
  String? id;
  @JsonKey(fromJson: stringFromJson)
  String? title;
  @JsonKey(fromJson: stringFromJson)
  String? startDateTime;
  @JsonKey(fromJson: stringFromJson)
  String? status;
  @JsonKey(fromJson: stringFromJson)
  String? enrolledCount;
  dynamic thumbnailUrl;

  AssignedWebinar({
    this.id,
    this.title,
    this.startDateTime,
    this.status,
    this.enrolledCount,
    this.thumbnailUrl,
  });

  factory AssignedWebinar.fromJson(Map<String, dynamic> json) {
    return _$AssignedWebinarFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AssignedWebinarToJson(this);
}
