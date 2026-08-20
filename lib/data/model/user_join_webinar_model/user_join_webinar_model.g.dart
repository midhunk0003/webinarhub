// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_join_webinar_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserJoinWebinarModel _$UserJoinWebinarModelFromJson(
  Map<String, dynamic> json,
) => UserJoinWebinarModel(
  statusCode: (json['statusCode'] as num?)?.toInt(),
  success: json['success'] as bool?,
  message: stringFromJson(json['message']),
  errorCode: stringFromJson(json['errorCode']),
  data:
      json['data'] == null
          ? null
          : JoinData.fromJson(json['data'] as Map<String, dynamic>),
  errors:
      json['errors'] == null
          ? null
          : Errors.fromJson(json['errors'] as Map<String, dynamic>),
  details: stringFromJson(json['details']),
);

Map<String, dynamic> _$UserJoinWebinarModelToJson(
  UserJoinWebinarModel instance,
) => <String, dynamic>{
  'statusCode': instance.statusCode,
  'success': instance.success,
  'message': instance.message,
  'errorCode': instance.errorCode,
  'data': instance.data,
  'errors': instance.errors,
  'details': instance.details,
};

Errors _$ErrorsFromJson(Map<String, dynamic> json) => Errors(
  additionalProp1:
      (json['additionalProp1'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  additionalProp2:
      (json['additionalProp2'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  additionalProp3:
      (json['additionalProp3'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$ErrorsToJson(Errors instance) => <String, dynamic>{
  'additionalProp1': instance.additionalProp1,
  'additionalProp2': instance.additionalProp2,
  'additionalProp3': instance.additionalProp3,
};

JoinData _$JoinDataFromJson(Map<String, dynamic> json) => JoinData(
  meetingUrl: stringFromJson(json['meetingUrl']),
  meetingId: stringFromJson(json['meetingId']),
  meetingPassword: stringFromJson(json['meetingPassword']),
);

Map<String, dynamic> _$JoinDataToJson(JoinData instance) => <String, dynamic>{
  'meetingUrl': instance.meetingUrl,
  'meetingId': instance.meetingId,
  'meetingPassword': instance.meetingPassword,
};
