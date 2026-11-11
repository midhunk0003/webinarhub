import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'monthly_transation_summery_model.g.dart';

@JsonSerializable()
class MonthlyTransationSummeryModel {
  @JsonKey(fromJson: stringFromJson)
  String? statusCode;

  @JsonKey(fromJson: stringFromJson)
  String? success;

  @JsonKey(fromJson: stringFromJson)
  String? message;

  @JsonKey(fromJson: stringFromJson)
  String? errorCode;

  List<MonthlySummeryDataList>? data;

  @JsonKey(fromJson: stringFromJson)
  String? errors;

  @JsonKey(fromJson: stringFromJson)
  String? details;

  MonthlyTransationSummeryModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory MonthlyTransationSummeryModel.fromJson(Map<String, dynamic> json) =>
      _$MonthlyTransationSummeryModelFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyTransationSummeryModelToJson(this);
}

@JsonSerializable()
class MonthlySummeryDataList {
  @JsonKey(fromJson: stringFromJson)
  String? year;

  @JsonKey(fromJson: stringFromJson)
  String? month;

  @JsonKey(fromJson: stringFromJson)
  String? monthName;

  @JsonKey(fromJson: stringFromJson)
  String? totalAmount;

  @JsonKey(fromJson: stringFromJson)
  String? totalSuccessfulPayments;

  @JsonKey(fromJson: stringFromJson)
  String? currency;

  MonthlySummeryDataList({
    this.year,
    this.month,
    this.monthName,
    this.totalAmount,
    this.totalSuccessfulPayments,
    this.currency,
  });

  factory MonthlySummeryDataList.fromJson(Map<String, dynamic> json) =>
      _$MonthlySummeryDataListFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlySummeryDataListToJson(this);
}
