// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_payment_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePaymentOrderModel _$CreatePaymentOrderModelFromJson(
  Map<String, dynamic> json,
) => CreatePaymentOrderModel(
  statusCode: stringFromJson(json['statusCode']),
  success: stringFromJson(json['success']),
  message: json['message'] as String?,
  data:
      json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CreatePaymentOrderModelToJson(
  CreatePaymentOrderModel instance,
) => <String, dynamic>{
  'statusCode': instance.statusCode,
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

Data _$DataFromJson(Map<String, dynamic> json) => Data(
  paymentId: stringFromJson(json['paymentId']),
  gateway: json['gateway'] as String?,
  clientConfig:
      json['clientConfig'] == null
          ? null
          : ClientConfig.fromJson(json['clientConfig'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
  'paymentId': instance.paymentId,
  'gateway': instance.gateway,
  'clientConfig': instance.clientConfig,
};

ClientConfig _$ClientConfigFromJson(Map<String, dynamic> json) => ClientConfig(
  key: json['key'] as String?,
  orderId: json['orderId'] as String?,
  amount: stringFromJson(json['amount']),
  currency: json['currency'] as String?,
);

Map<String, dynamic> _$ClientConfigToJson(ClientConfig instance) =>
    <String, dynamic>{
      'key': instance.key,
      'orderId': instance.orderId,
      'amount': instance.amount,
      'currency': instance.currency,
    };
