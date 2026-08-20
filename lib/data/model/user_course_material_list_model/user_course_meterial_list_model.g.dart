// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_course_meterial_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserCourseMeterialListModel _$UserCourseMeterialListModelFromJson(
  Map<String, dynamic> json,
) => UserCourseMeterialListModel(
  statusCode: stringFromJson(json['statusCode']),
  success: stringFromJson(json['success']),
  message: stringFromJson(json['message']),
  errorCode: stringFromJson(json['errorCode']),
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => UserMaterialData.fromJson(e as Map<String, dynamic>))
          .toList(),
  errors: json['errors'],
  details: json['details'],
);

Map<String, dynamic> _$UserCourseMeterialListModelToJson(
  UserCourseMeterialListModel instance,
) => <String, dynamic>{
  'statusCode': instance.statusCode,
  'success': instance.success,
  'message': instance.message,
  'errorCode': instance.errorCode,
  'data': instance.data,
  'errors': instance.errors,
  'details': instance.details,
};

UserMaterialData _$UserMaterialDataFromJson(Map<String, dynamic> json) =>
    UserMaterialData(
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

Map<String, dynamic> _$UserMaterialDataToJson(UserMaterialData instance) =>
    <String, dynamic>{
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
