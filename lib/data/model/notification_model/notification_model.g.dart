// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      statusCode: stringFromJson(json['statusCode']),
      success: stringFromJson(json['success']),
      message: stringFromJson(json['message']),
      errorCode: stringFromJson(json['errorCode']),
      data:
          json['data'] == null
              ? null
              : NotificationData.fromJson(json['data'] as Map<String, dynamic>),
      errors: stringFromJson(json['errors']),
      details: stringFromJson(json['details']),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'success': instance.success,
      'message': instance.message,
      'errorCode': instance.errorCode,
      'data': instance.data,
      'errors': instance.errors,
      'details': instance.details,
    };

NotificationData _$NotificationDataFromJson(Map<String, dynamic> json) =>
    NotificationData(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      totalCount: stringFromJson(json['totalCount']),
      page: stringFromJson(json['page']),
      pageSize: stringFromJson(json['pageSize']),
      totalPages: stringFromJson(json['totalPages']),
      hasNextPage: stringFromJson(json['hasNextPage']),
      hasPreviousPage: stringFromJson(json['hasPreviousPage']),
    );

Map<String, dynamic> _$NotificationDataToJson(NotificationData instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalCount': instance.totalCount,
      'page': instance.page,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
      'hasNextPage': instance.hasNextPage,
      'hasPreviousPage': instance.hasPreviousPage,
    };

NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) =>
    NotificationItem(
      id: stringFromJson(json['id']),
      title: stringFromJson(json['title']),
      message: stringFromJson(json['message']),
      event: stringFromJson(json['event']),
      isRead: stringFromJson(json['isRead']),
      createdAt: stringFromJson(json['createdAt']),
    );

Map<String, dynamic> _$NotificationItemToJson(NotificationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'event': instance.event,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt,
    };
