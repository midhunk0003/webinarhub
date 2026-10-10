import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'payment_verify_model.g.dart';

@JsonSerializable()
class PaymentVerifyModel {
  @JsonKey(fromJson: stringFromJson)
  String? statusCode;

  @JsonKey(fromJson: stringFromJson)
  String? success;

  @JsonKey(fromJson: stringFromJson)
  String? message;

  @JsonKey(fromJson: stringFromJson)
  String? errorCode;

  Data? data;

  Errors? errors;

  @JsonKey(fromJson: stringFromJson)
  String? details;

  PaymentVerifyModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory PaymentVerifyModel.fromJson(Map<String, dynamic> json) {
    return _$PaymentVerifyModelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$PaymentVerifyModelToJson(this);
  }
}

@JsonSerializable()
class Data {
  @JsonKey(fromJson: stringFromJson)
  String? paymentId;

  @JsonKey(fromJson: stringFromJson)
  String? status;

  Data({this.paymentId, this.status});

  factory Data.fromJson(Map<String, dynamic> json) {
    return _$DataFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$DataToJson(this);
  }
}

@JsonSerializable()
class Errors {
  @JsonKey(fromJson: stringListFromJson)
  List<String>? additionalProp1;

  @JsonKey(fromJson: stringListFromJson)
  List<String>? additionalProp2;

  @JsonKey(fromJson: stringListFromJson)
  List<String>? additionalProp3;

  Errors({this.additionalProp1, this.additionalProp2, this.additionalProp3});

  factory Errors.fromJson(Map<String, dynamic> json) {
    return _$ErrorsFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$ErrorsToJson(this);
  }
}
