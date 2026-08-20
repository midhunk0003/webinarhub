// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_full_list_webinar_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserFullListWebinarModel _$UserFullListWebinarModelFromJson(
  Map<String, dynamic> json,
) => UserFullListWebinarModel(
  statusCode: stringFromJson(json['statusCode']),
  success: stringFromJson(json['success']),
  message: stringFromJson(json['message']),
  errorCode: stringFromJson(json['errorCode']),
  data:
      json['data'] == null
          ? null
          : AllWebinarData.fromJson(json['data'] as Map<String, dynamic>),
  errors: stringFromJson(json['errors']),
  details: stringFromJson(json['details']),
);

Map<String, dynamic> _$UserFullListWebinarModelToJson(
  UserFullListWebinarModel instance,
) => <String, dynamic>{
  'statusCode': instance.statusCode,
  'success': instance.success,
  'message': instance.message,
  'errorCode': instance.errorCode,
  'data': instance.data,
  'errors': instance.errors,
  'details': instance.details,
};

AllWebinarData _$AllWebinarDataFromJson(Map<String, dynamic> json) =>
    AllWebinarData(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => AllWebinarItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      totalCount: stringFromJson(json['totalCount']),
      page: stringFromJson(json['page']),
      pageSize: stringFromJson(json['pageSize']),
      totalPages: stringFromJson(json['totalPages']),
      hasNextPage: stringFromJson(json['hasNextPage']),
      hasPreviousPage: stringFromJson(json['hasPreviousPage']),
    );

Map<String, dynamic> _$AllWebinarDataToJson(AllWebinarData instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalCount': instance.totalCount,
      'page': instance.page,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
      'hasNextPage': instance.hasNextPage,
      'hasPreviousPage': instance.hasPreviousPage,
    };

AllWebinarItem _$AllWebinarItemFromJson(Map<String, dynamic> json) =>
    AllWebinarItem(
      id: stringFromJson(json['id']),
      title: stringFromJson(json['title']),
      description: stringFromJson(json['description']),
      category: stringFromJson(json['category']),
      thumbnailUrl: stringFromJson(json['thumbnailUrl']),
      startDateTime: stringFromJson(json['startDateTime']),
      endDateTime: stringFromJson(json['endDateTime']),
      status: stringFromJson(json['status']),
      statusName: stringFromJson(json['statusName']),
      trainerName: stringFromJson(json['trainerName']),
      isPaid: stringFromJson(json['isPaid']),
      price: stringFromJson(json['price']),
      paymentStatus: stringFromJson(json['paymentStatus']),
      platform: stringFromJson(json['platform']),
      paymentStatusName: stringFromJson(json['paymentStatusName']),
      platformName: stringFromJson(json['platformName']),
      enrollmentStatus: stringFromJson(json['enrollmentStatus']),
      enrollmentStatusName: stringFromJson(json['enrollmentStatusName']),
      canJoin: stringFromJson(json['canJoin']),
    );

Map<String, dynamic> _$AllWebinarItemToJson(AllWebinarItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'thumbnailUrl': instance.thumbnailUrl,
      'startDateTime': instance.startDateTime,
      'endDateTime': instance.endDateTime,
      'status': instance.status,
      'statusName': instance.statusName,
      'trainerName': instance.trainerName,
      'isPaid': instance.isPaid,
      'price': instance.price,
      'paymentStatus': instance.paymentStatus,
      'platform': instance.platform,
      'paymentStatusName': instance.paymentStatusName,
      'platformName': instance.platformName,
      'enrollmentStatus': instance.enrollmentStatus,
      'enrollmentStatusName': instance.enrollmentStatusName,
      'canJoin': instance.canJoin,
    };
