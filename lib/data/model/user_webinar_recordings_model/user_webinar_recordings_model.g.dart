// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_webinar_recordings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserWebinarRecordingsModel _$UserWebinarRecordingsModelFromJson(
  Map<String, dynamic> json,
) => UserWebinarRecordingsModel(
  statusCode: (json['statusCode'] as num?)?.toInt(),
  success: json['success'] as bool?,
  message: stringFromJson(json['message']),
  errorCode: stringFromJson(json['errorCode']),
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => WebinarRecordinsData.fromJson(e as Map<String, dynamic>))
          .toList(),
  errors:
      json['errors'] == null
          ? null
          : Errors.fromJson(json['errors'] as Map<String, dynamic>),
  details: stringFromJson(json['details']),
);

Map<String, dynamic> _$UserWebinarRecordingsModelToJson(
  UserWebinarRecordingsModel instance,
) => <String, dynamic>{
  'statusCode': instance.statusCode,
  'success': instance.success,
  'message': instance.message,
  'errorCode': instance.errorCode,
  'data': instance.data,
  'errors': instance.errors,
  'details': instance.details,
};

WebinarRecordinsData _$WebinarRecordinsDataFromJson(
  Map<String, dynamic> json,
) => WebinarRecordinsData(
  id: (json['id'] as num?)?.toInt(),
  webinarId: (json['webinarId'] as num?)?.toInt(),
  title: stringFromJson(json['title']),
  recordingUrl: stringFromJson(json['recordingUrl']),
  duration: stringFromJson(json['duration']),
  uploadedByUserId: stringFromJson(json['uploadedByUserId']),
  uploadedByUserName: stringFromJson(json['uploadedByUserName']),
  isVisibleToParticipants: json['isVisibleToParticipants'] as bool?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$WebinarRecordinsDataToJson(
  WebinarRecordinsData instance,
) => <String, dynamic>{
  'id': instance.id,
  'webinarId': instance.webinarId,
  'title': instance.title,
  'recordingUrl': instance.recordingUrl,
  'duration': instance.duration,
  'uploadedByUserId': instance.uploadedByUserId,
  'uploadedByUserName': instance.uploadedByUserName,
  'isVisibleToParticipants': instance.isVisibleToParticipants,
  'createdAt': instance.createdAt?.toIso8601String(),
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
