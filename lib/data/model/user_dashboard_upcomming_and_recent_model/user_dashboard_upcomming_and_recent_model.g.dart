// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dashboard_upcomming_and_recent_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDashboardUpcommingAndRecentModel
_$UserDashboardUpcommingAndRecentModelFromJson(Map<String, dynamic> json) =>
    UserDashboardUpcommingAndRecentModel(
      statusCode: stringFromJson(json['statusCode']),
      success: stringFromJson(json['success']),
      message: stringFromJson(json['message']),
      errorCode: stringFromJson(json['errorCode']),
      data:
          json['data'] == null
              ? null
              : UserUpcommingAndAssighData.fromJson(
                json['data'] as Map<String, dynamic>,
              ),
      errors: json['errors'],
      details: json['details'],
    );

Map<String, dynamic> _$UserDashboardUpcommingAndRecentModelToJson(
  UserDashboardUpcommingAndRecentModel instance,
) => <String, dynamic>{
  'statusCode': instance.statusCode,
  'success': instance.success,
  'message': instance.message,
  'errorCode': instance.errorCode,
  'data': instance.data,
  'errors': instance.errors,
  'details': instance.details,
};

UserUpcommingAndAssighData _$UserUpcommingAndAssighDataFromJson(
  Map<String, dynamic> json,
) => UserUpcommingAndAssighData(
  upcomingWebinar:
      json['upcomingWebinar'] == null
          ? null
          : UserUpcomingWebinar.fromJson(
            json['upcomingWebinar'] as Map<String, dynamic>,
          ),
  assignedWebinars:
      (json['assignedWebinars'] as List<dynamic>?)
          ?.map((e) => UserAssignedWebinar.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$UserUpcommingAndAssighDataToJson(
  UserUpcommingAndAssighData instance,
) => <String, dynamic>{
  'upcomingWebinar': instance.upcomingWebinar,
  'assignedWebinars': instance.assignedWebinars,
};

UserUpcomingWebinar _$UserUpcomingWebinarFromJson(Map<String, dynamic> json) =>
    UserUpcomingWebinar(
      webinarId: stringFromJson(json['webinarId']),
      title: stringFromJson(json['title']),
      startDate: stringFromJson(json['startDate']),
      endDate: stringFromJson(json['endDate']),
      status: stringFromJson(json['status']),
      meetingPlatform: stringFromJson(json['meetingPlatform']),
      meetingUrl: stringFromJson(json['meetingUrl']),
      thumbnailUrl: stringFromJson(json['thumbnailUrl']),
      isPaid: stringFromJson(json['isPaid']),
      price: stringFromJson(json['price']),
    );

Map<String, dynamic> _$UserUpcomingWebinarToJson(
  UserUpcomingWebinar instance,
) => <String, dynamic>{
  'webinarId': instance.webinarId,
  'title': instance.title,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'status': instance.status,
  'meetingPlatform': instance.meetingPlatform,
  'meetingUrl': instance.meetingUrl,
  'thumbnailUrl': instance.thumbnailUrl,
  'isPaid': instance.isPaid,
  'price': instance.price,
};

UserAssignedWebinar _$UserAssignedWebinarFromJson(Map<String, dynamic> json) =>
    UserAssignedWebinar(
      webinarId: stringFromJson(json['webinarId']),
      title: stringFromJson(json['title']),
      startDate: stringFromJson(json['startDate']),
      status: stringFromJson(json['status']),
      thumbnailUrl: stringFromJson(json['thumbnailUrl']),
      isPaid: stringFromJson(json['isPaid']),
      price: stringFromJson(json['price']),
    );

Map<String, dynamic> _$UserAssignedWebinarToJson(
  UserAssignedWebinar instance,
) => <String, dynamic>{
  'webinarId': instance.webinarId,
  'title': instance.title,
  'startDate': instance.startDate,
  'status': instance.status,
  'thumbnailUrl': instance.thumbnailUrl,
  'isPaid': instance.isPaid,
  'price': instance.price,
};
