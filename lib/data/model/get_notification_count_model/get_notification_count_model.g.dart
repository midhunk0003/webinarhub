// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_notification_count_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetNotificationCountModel _$GetNotificationCountModelFromJson(
  Map<String, dynamic> json,
) => GetNotificationCountModel(
  statusCode: stringFromJson(json['statusCode']),
  success: stringFromJson(json['success']),
  message: stringFromJson(json['message']),
  errorCode: stringFromJson(json['errorCode']),
  data: stringFromJson(json['data']),
  errors: stringFromJson(json['errors']),
  details: stringFromJson(json['details']),
);

Map<String, dynamic> _$GetNotificationCountModelToJson(
  GetNotificationCountModel instance,
) => <String, dynamic>{
  'statusCode': instance.statusCode,
  'success': instance.success,
  'message': instance.message,
  'errorCode': instance.errorCode,
  'data': instance.data,
  'errors': instance.errors,
  'details': instance.details,
};
