// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_course_detail_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainerCourseDetailModel _$TrainerCourseDetailModelFromJson(
  Map<String, dynamic> json,
) => TrainerCourseDetailModel(
  statusCode: stringFromJson(json['statusCode']),
  success: stringFromJson(json['success']),
  message: stringFromJson(json['message']),
  errorCode: stringFromJson(json['errorCode']),
  data:
      json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
  errors: stringFromJson(json['errors']),
  details: stringFromJson(json['details']),
);

Map<String, dynamic> _$TrainerCourseDetailModelToJson(
  TrainerCourseDetailModel instance,
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
  title: stringFromJson(json['title']),
  description: stringFromJson(json['description']),
  category: stringFromJson(json['category']),
  thumbnailUrl: stringFromJson(json['thumbnailUrl']),
  startDateTime: stringFromJson(json['startDateTime']),
  endDateTime: stringFromJson(json['endDateTime']),
  status: stringFromJson(json['status']),
  statusName: stringFromJson(json['statusName']),
  platform: stringFromJson(json['platform']),
  language: stringFromJson(json['language']),
  type: stringFromJson(json['type']),
  typeName: stringFromJson(json['typeName']),
  platformName: stringFromJson(json['platformName']),
  meetingLink: stringFromJson(json['meetingLink']),
  meetingId: stringFromJson(json['meetingId']),
  maxParticipants: stringFromJson(json['maxParticipants']),
  isPaid: stringFromJson(json['isPaid']),
  price: stringFromJson(json['price']),
  trainerId: stringFromJson(json['trainerId']),
  trainerName: stringFromJson(json['trainerName']),
  trainerEmail: stringFromJson(json['trainerEmail']),
  enrolledParticipantCount: stringFromJson(json['enrolledParticipantCount']),
  pendingParticipantCount: stringFromJson(json['pendingParticipantCount']),
  materialCount: stringFromJson(json['materialCount']),
  recordingCount: stringFromJson(json['recordingCount']),
  createdAt: stringFromJson(json['createdAt']),
  updatedAt: stringFromJson(json['updatedAt']),
);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'thumbnailUrl': instance.thumbnailUrl,
  'startDateTime': instance.startDateTime,
  'endDateTime': instance.endDateTime,
  'status': instance.status,
  'statusName': instance.statusName,
  'platform': instance.platform,
  'language': instance.language,
  'type': instance.type,
  'typeName': instance.typeName,
  'platformName': instance.platformName,
  'meetingLink': instance.meetingLink,
  'meetingId': instance.meetingId,
  'maxParticipants': instance.maxParticipants,
  'isPaid': instance.isPaid,
  'price': instance.price,
  'trainerId': instance.trainerId,
  'trainerName': instance.trainerName,
  'trainerEmail': instance.trainerEmail,
  'enrolledParticipantCount': instance.enrolledParticipantCount,
  'pendingParticipantCount': instance.pendingParticipantCount,
  'materialCount': instance.materialCount,
  'recordingCount': instance.recordingCount,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
