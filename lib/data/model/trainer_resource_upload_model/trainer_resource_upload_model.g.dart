// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_resource_upload_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainerResourceUploadModel _$TrainerResourceUploadModelFromJson(
  Map<String, dynamic> json,
) => TrainerResourceUploadModel(
  statusCode: stringFromJson(json['statusCode']),
  success: stringFromJson(json['success']),
  message: stringFromJson(json['message']),
  errorCode: json['errorCode'],
  data:
      json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
  errors: json['errors'],
  details: json['details'],
);

Map<String, dynamic> _$TrainerResourceUploadModelToJson(
  TrainerResourceUploadModel instance,
) => <String, dynamic>{
  'statusCode': instance.statusCode,
  'success': instance.success,
  'message': instance.message,
  'errorCode': instance.errorCode,
  'data': instance.data,
  'errors': instance.errors,
  'details': instance.details,
};

Data _$DataFromJson(Map<String, dynamic> json) => Data(
  id: stringFromJson(json['id']),
  webinarId: stringFromJson(json['webinarId']),
  fileName: stringFromJson(json['fileName']),
  fileUrl: stringFromJson(json['fileUrl']),
  fileType: stringFromJson(json['fileType']),
  fileSize: stringFromJson(json['fileSize']),
  uploadedByUserId: stringFromJson(json['uploadedByUserId']),
  uploadedByUserName: stringFromJson(json['uploadedByUserName']),
  isVisibleToParticipants: stringFromJson(json['isVisibleToParticipants']),
  createdAt: stringFromJson(json['createdAt']),
);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
  'id': instance.id,
  'webinarId': instance.webinarId,
  'fileName': instance.fileName,
  'fileUrl': instance.fileUrl,
  'fileType': instance.fileType,
  'fileSize': instance.fileSize,
  'uploadedByUserId': instance.uploadedByUserId,
  'uploadedByUserName': instance.uploadedByUserName,
  'isVisibleToParticipants': instance.isVisibleToParticipants,
  'createdAt': instance.createdAt,
};
