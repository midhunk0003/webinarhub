// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_verify_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentVerifyModel _$PaymentVerifyModelFromJson(Map<String, dynamic> json) =>
    PaymentVerifyModel(
      statusCode: stringFromJson(json['statusCode']),
      success: stringFromJson(json['success']),
      message: stringFromJson(json['message']),
      errorCode: stringFromJson(json['errorCode']),
      data:
          json['data'] == null
              ? null
              : Data.fromJson(json['data'] as Map<String, dynamic>),
      errors:
          json['errors'] == null
              ? null
              : Errors.fromJson(json['errors'] as Map<String, dynamic>),
      details: stringFromJson(json['details']),
    );

Map<String, dynamic> _$PaymentVerifyModelToJson(PaymentVerifyModel instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'success': instance.success,
      'message': instance.message,
      'errorCode': instance.errorCode,
      'data': instance.data,
      'errors': instance.errors,
      'details': instance.details,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
  paymentId: stringFromJson(json['paymentId']),
  status: stringFromJson(json['status']),
);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
  'paymentId': instance.paymentId,
  'status': instance.status,
};

Errors _$ErrorsFromJson(Map<String, dynamic> json) => Errors(
  additionalProp1: stringListFromJson(json['additionalProp1']),
  additionalProp2: stringListFromJson(json['additionalProp2']),
  additionalProp3: stringListFromJson(json['additionalProp3']),
);

Map<String, dynamic> _$ErrorsToJson(Errors instance) => <String, dynamic>{
  'additionalProp1': instance.additionalProp1,
  'additionalProp2': instance.additionalProp2,
  'additionalProp3': instance.additionalProp3,
};
