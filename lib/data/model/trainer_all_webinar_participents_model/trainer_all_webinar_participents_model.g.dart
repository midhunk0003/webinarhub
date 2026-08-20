// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_all_webinar_participents_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainerAllWebinarParticipentsModel _$TrainerAllWebinarParticipentsModelFromJson(
  Map<String, dynamic> json,
) => TrainerAllWebinarParticipentsModel(
  statusCode: (json['statusCode'] as num?)?.toInt(),
  success: json['success'] as bool?,
  message: stringFromJson(json['message']),
  errorCode: json['errorCode'],
  data:
      json['data'] == null
          ? null
          : ParticipantData.fromJson(json['data'] as Map<String, dynamic>),
  errors: json['errors'],
  details: json['details'],
);

Map<String, dynamic> _$TrainerAllWebinarParticipentsModelToJson(
  TrainerAllWebinarParticipentsModel instance,
) => <String, dynamic>{
  'statusCode': instance.statusCode,
  'success': instance.success,
  'message': instance.message,
  'errorCode': instance.errorCode,
  'data': instance.data,
  'errors': instance.errors,
  'details': instance.details,
};

ParticipantData _$ParticipantDataFromJson(Map<String, dynamic> json) =>
    ParticipantData(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ParticipantItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      totalCount: stringFromJson(json['totalCount']),
      page: stringFromJson(json['page']),
      pageSize: stringFromJson(json['pageSize']),
      totalPages: stringFromJson(json['totalPages']),
      hasNextPage: json['hasNextPage'] as bool?,
      hasPreviousPage: json['hasPreviousPage'] as bool?,
    );

Map<String, dynamic> _$ParticipantDataToJson(ParticipantData instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalCount': instance.totalCount,
      'page': instance.page,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
      'hasNextPage': instance.hasNextPage,
      'hasPreviousPage': instance.hasPreviousPage,
    };

ParticipantItem _$ParticipantItemFromJson(Map<String, dynamic> json) =>
    ParticipantItem(
      id: stringFromJson(json['id']),
      webinarId: stringFromJson(json['webinarId']),
      userId: stringFromJson(json['userId']),
      userFullName: stringFromJson(json['userFullName']),
      userEmail: stringFromJson(json['userEmail']),
      enrollmentStatus: stringFromJson(json['enrollmentStatus']),
      enrollmentStatusName: stringFromJson(json['enrollmentStatusName']),
      paymentStatus: stringFromJson(json['paymentStatus']),
      paymentStatusName: stringFromJson(json['paymentStatusName']),
      enrollmentSource: stringFromJson(json['enrollmentSource']),
      enrollmentSourceName: stringFromJson(json['enrollmentSourceName']),
      enrolledByUserId: stringFromJson(json['enrolledByUserId']),
      enrolledByUserName: stringFromJson(json['enrolledByUserName']),
      enrollmentDate: stringFromJson(json['enrollmentDate']),
    );

Map<String, dynamic> _$ParticipantItemToJson(ParticipantItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'webinarId': instance.webinarId,
      'userId': instance.userId,
      'userFullName': instance.userFullName,
      'userEmail': instance.userEmail,
      'enrollmentStatus': instance.enrollmentStatus,
      'enrollmentStatusName': instance.enrollmentStatusName,
      'paymentStatus': instance.paymentStatus,
      'paymentStatusName': instance.paymentStatusName,
      'enrollmentSource': instance.enrollmentSource,
      'enrollmentSourceName': instance.enrollmentSourceName,
      'enrolledByUserId': instance.enrolledByUserId,
      'enrolledByUserName': instance.enrolledByUserName,
      'enrollmentDate': instance.enrollmentDate,
    };
