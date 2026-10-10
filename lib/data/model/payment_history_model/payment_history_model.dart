import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'payment_history_model.g.dart';

@JsonSerializable()
class PaymentHistoryModel {
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

  PaymentHistoryModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentHistoryModelToJson(this);
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
  String? paymentId;

  @JsonKey(fromJson: stringFromJson)
  String? webinarId;

  @JsonKey(fromJson: stringFromJson)
  String? webinarTitle;

  @JsonKey(fromJson: stringFromJson)
  String? amount;

  @JsonKey(fromJson: stringFromJson)
  String? currency;

  @JsonKey(fromJson: stringFromJson)
  String? status;

  @JsonKey(fromJson: stringFromJson)
  String? statusName;

  @JsonKey(fromJson: stringFromJson)
  String? paymentMethod;

  @JsonKey(fromJson: stringFromJson)
  String? paymentMethodName;

  @JsonKey(fromJson: stringFromJson)
  String? gatewayPaymentId;

  @JsonKey(fromJson: stringFromJson)
  String? transactionId;

  @JsonKey(fromJson: stringFromJson)
  String? paidAt;

  @JsonKey(fromJson: stringFromJson)
  String? createdAt;

  Item({
    this.paymentId,
    this.webinarId,
    this.webinarTitle,
    this.amount,
    this.currency,
    this.status,
    this.statusName,
    this.paymentMethod,
    this.paymentMethodName,
    this.gatewayPaymentId,
    this.transactionId,
    this.paidAt,
    this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}

@JsonSerializable()
class Errors {
  List<String>? additionalProp1;
  List<String>? additionalProp2;
  List<String>? additionalProp3;

  Errors({this.additionalProp1, this.additionalProp2, this.additionalProp3});

  factory Errors.fromJson(Map<String, dynamic> json) => _$ErrorsFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorsToJson(this);
}
