// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_payment_gate_ways_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailablePaymentGateWaysModel _$AvailablePaymentGateWaysModelFromJson(
  Map<String, dynamic> json,
) => AvailablePaymentGateWaysModel(
  statusCode: stringFromJson(json['statusCode']),
  success: stringFromJson(json['success']),
  message: stringFromJson(json['message']),
  errorCode: stringFromJson(json['errorCode']),
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => PaymentGateWaysData.fromJson(e as Map<String, dynamic>))
          .toList(),
  errors: stringFromJson(json['errors']),
  details: stringFromJson(json['details']),
);

Map<String, dynamic> _$AvailablePaymentGateWaysModelToJson(
  AvailablePaymentGateWaysModel instance,
) => <String, dynamic>{
  'statusCode': instance.statusCode,
  'success': instance.success,
  'message': instance.message,
  'errorCode': instance.errorCode,
  'data': instance.data,
  'errors': instance.errors,
  'details': instance.details,
};

PaymentGateWaysData _$PaymentGateWaysDataFromJson(Map<String, dynamic> json) =>
    PaymentGateWaysData(
      id: stringFromJson(json['id']),
      gatewayType: stringFromJson(json['gatewayType']),
      displayName: stringFromJson(json['displayName']),
      description: stringFromJson(json['description']),
      logoUrl: stringFromJson(json['logoUrl']),
      isSandbox: stringFromJson(json['isSandbox']),
    );

Map<String, dynamic> _$PaymentGateWaysDataToJson(
  PaymentGateWaysData instance,
) => <String, dynamic>{
  'id': instance.id,
  'gatewayType': instance.gatewayType,
  'displayName': instance.displayName,
  'description': instance.description,
  'logoUrl': instance.logoUrl,
  'isSandbox': instance.isSandbox,
};
