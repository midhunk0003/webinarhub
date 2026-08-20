import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'trainer_over_view_model.g.dart';

@JsonSerializable()
class TrainerOverViewModel {
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

  TrainerOverViewModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory TrainerOverViewModel.fromJson(Map<String, dynamic> json) {
    return _$TrainerOverViewModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TrainerOverViewModelToJson(this);
}

@JsonSerializable()
class Data {
  @JsonKey(fromJson: stringFromJson)
  String? totalWebinars;

  @JsonKey(fromJson: stringFromJson)
  String? draftWebinars;

  @JsonKey(fromJson: stringFromJson)
  String? publishedWebinars;

  @JsonKey(fromJson: stringFromJson)
  String? upcomingWebinars;

  @JsonKey(fromJson: stringFromJson)
  String? completedWebinars;

  @JsonKey(fromJson: stringFromJson)
  String? cancelledWebinars;

  @JsonKey(fromJson: stringFromJson)
  String? totalParticipants;

  @JsonKey(fromJson: stringFromJson)
  String? materialsUploaded;

  @JsonKey(fromJson: stringFromJson)
  String? notificationsSent;

  Data({
    this.totalWebinars,
    this.draftWebinars,
    this.publishedWebinars,
    this.upcomingWebinars,
    this.completedWebinars,
    this.cancelledWebinars,
    this.totalParticipants,
    this.materialsUploaded,
    this.notificationsSent,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return _$DataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
