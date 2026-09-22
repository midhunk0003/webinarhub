import 'package:json_annotation/json_annotation.dart';

part 'available_payment_gate_ways_model.g.dart';

String? stringFromJson(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

@JsonSerializable()
class AvailablePaymentGateWaysModel {
  @JsonKey(fromJson: stringFromJson)
  String? statusCode;

  @JsonKey(fromJson: stringFromJson)
  String? success;

  @JsonKey(fromJson: stringFromJson)
  String? message;

  @JsonKey(fromJson: stringFromJson)
  String? errorCode;

  List<PaymentGateWaysData>? data;

  @JsonKey(fromJson: stringFromJson)
  String? errors;

  @JsonKey(fromJson: stringFromJson)
  String? details;

  AvailablePaymentGateWaysModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory AvailablePaymentGateWaysModel.fromJson(Map<String, dynamic> json) {
    return _$AvailablePaymentGateWaysModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AvailablePaymentGateWaysModelToJson(this);
}

@JsonSerializable()
class PaymentGateWaysData {
  @JsonKey(fromJson: stringFromJson)
  String? id;

  @JsonKey(fromJson: stringFromJson)
  String? gatewayType;

  @JsonKey(fromJson: stringFromJson)
  String? displayName;

  @JsonKey(fromJson: stringFromJson)
  String? description;

  @JsonKey(fromJson: stringFromJson)
  String? logoUrl;

  @JsonKey(fromJson: stringFromJson)
  String? isSandbox;

  PaymentGateWaysData({
    this.id,
    this.gatewayType,
    this.displayName,
    this.description,
    this.logoUrl,
    this.isSandbox,
  });

  factory PaymentGateWaysData.fromJson(Map<String, dynamic> json) =>
      _$PaymentGateWaysDataFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentGateWaysDataToJson(this);
}
