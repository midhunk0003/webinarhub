import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'create_payment_order_model.g.dart';

// ============================================================
// CREATE PAYMENT ORDER MODEL
// ============================================================

@JsonSerializable()
class CreatePaymentOrderModel {
  @JsonKey(fromJson: stringFromJson)
  String? statusCode;

  @JsonKey(fromJson: stringFromJson)
  String? success;

  String? message;

  Data? data;

  CreatePaymentOrderModel({
    this.statusCode,
    this.success,
    this.message,
    this.data,
  });

  factory CreatePaymentOrderModel.fromJson(Map<String, dynamic> json) {
    return _$CreatePaymentOrderModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CreatePaymentOrderModelToJson(this);
}

// ============================================================
// DATA
// ============================================================

@JsonSerializable()
class Data {
  @JsonKey(fromJson: stringFromJson)
  String? paymentId;

  String? gateway;

  ClientConfig? clientConfig;

  Data({this.paymentId, this.gateway, this.clientConfig});

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}

// ============================================================
// CLIENT CONFIG
// ============================================================

@JsonSerializable()
class ClientConfig {
  String? key;

  String? orderId;

  @JsonKey(fromJson: stringFromJson)
  String? amount;

  String? currency;

  ClientConfig({this.key, this.orderId, this.amount, this.currency});

  factory ClientConfig.fromJson(Map<String, dynamic> json) =>
      _$ClientConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ClientConfigToJson(this);
}
