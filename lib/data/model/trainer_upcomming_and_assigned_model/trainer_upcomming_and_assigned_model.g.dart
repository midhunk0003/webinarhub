// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_upcomming_and_assigned_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainerUpcommingAndAssignedModel _$TrainerUpcommingAndAssignedModelFromJson(
  Map<String, dynamic> json,
) => TrainerUpcommingAndAssignedModel(
  statusCode: (json['statusCode'] as num?)?.toInt(),
  success: json['success'] as bool?,
  message: stringFromJson(json['message']),
  data:
      json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
  errors: json['errors'],
  details: json['details'],
);

Map<String, dynamic> _$TrainerUpcommingAndAssignedModelToJson(
  TrainerUpcommingAndAssignedModel instance,
) => <String, dynamic>{
  'statusCode': instance.statusCode,
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
  'errors': instance.errors,
  'details': instance.details,
};

Data _$DataFromJson(Map<String, dynamic> json) => Data(
  upcomingWebinar:
      json['upcomingWebinar'] == null
          ? null
          : UpcomingWebinar.fromJson(
            json['upcomingWebinar'] as Map<String, dynamic>,
          ),
  assignedWebinars:
      (json['assignedWebinars'] as List<dynamic>?)
          ?.map((e) => AssignedWebinar.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
  'upcomingWebinar': instance.upcomingWebinar,
  'assignedWebinars': instance.assignedWebinars,
};

UpcomingWebinar _$UpcomingWebinarFromJson(Map<String, dynamic> json) =>
    UpcomingWebinar(
      id: stringFromJson(json['id']),
      title: stringFromJson(json['title']),
      startDateTime: stringFromJson(json['startDateTime']),
      endDateTime: stringFromJson(json['endDateTime']),
      thumbnailUrl: stringFromJson(json['thumbnailUrl']),
      status: stringFromJson(json['status']),
      enrolledCount: stringFromJson(json['enrolledCount']),
      platform: stringFromJson(json['platform']),
      meetingUrl: stringFromJson(json['meetingUrl']),
    );

Map<String, dynamic> _$UpcomingWebinarToJson(UpcomingWebinar instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'startDateTime': instance.startDateTime,
      'endDateTime': instance.endDateTime,
      'thumbnailUrl': instance.thumbnailUrl,
      'status': instance.status,
      'enrolledCount': instance.enrolledCount,
      'platform': instance.platform,
      'meetingUrl': instance.meetingUrl,
    };

AssignedWebinar _$AssignedWebinarFromJson(Map<String, dynamic> json) =>
    AssignedWebinar(
      id: stringFromJson(json['id']),
      title: stringFromJson(json['title']),
      startDateTime: stringFromJson(json['startDateTime']),
      status: stringFromJson(json['status']),
      enrolledCount: stringFromJson(json['enrolledCount']),
      thumbnailUrl: json['thumbnailUrl'],
    );

Map<String, dynamic> _$AssignedWebinarToJson(AssignedWebinar instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'startDateTime': instance.startDateTime,
      'status': instance.status,
      'enrolledCount': instance.enrolledCount,
      'thumbnailUrl': instance.thumbnailUrl,
    };
