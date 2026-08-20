// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_full_list_webinar_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainerFullListWebinarModel _$TrainerFullListWebinarModelFromJson(
  Map<String, dynamic> json,
) => TrainerFullListWebinarModel(
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

Map<String, dynamic> _$TrainerFullListWebinarModelToJson(
  TrainerFullListWebinarModel instance,
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
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
  totalCount: stringFromJson(json['totalCount']),
  page: stringFromJson(json['page']),
  pageSize: stringFromJson(json['pageSize']),
  totalPages: stringFromJson(json['totalPages']),
  hasNextPage: stringFromJson(json['hasNextPage']),
  hasPreviousPage: stringFromJson(json['hasPreviousPage']),
);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
  'items': instance.items,
  'totalCount': instance.totalCount,
  'page': instance.page,
  'pageSize': instance.pageSize,
  'totalPages': instance.totalPages,
  'hasNextPage': instance.hasNextPage,
  'hasPreviousPage': instance.hasPreviousPage,
};

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
  id: stringFromJson(json['id']),
  title: stringFromJson(json['title']),
  category: stringFromJson(json['category']),
  thumbnailUrl: stringFromJson(json['thumbnailUrl']),
  startDateTime: stringFromJson(json['startDateTime']),
  endDateTime: stringFromJson(json['endDateTime']),
  status: stringFromJson(json['status']),
  statusName: stringFromJson(json['statusName']),
  platform: stringFromJson(json['platform']),
  platformName: stringFromJson(json['platformName']),
  trainerId: stringFromJson(json['trainerId']),
  trainerName: stringFromJson(json['trainerName']),
  isPaid: stringFromJson(json['isPaid']),
  price: stringFromJson(json['price']),
  maxParticipants: stringFromJson(json['maxParticipants']),
  enrolledParticipantCount: stringFromJson(json['enrolledParticipantCount']),
  createdAt: stringFromJson(json['createdAt']),
);

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'category': instance.category,
  'thumbnailUrl': instance.thumbnailUrl,
  'startDateTime': instance.startDateTime,
  'endDateTime': instance.endDateTime,
  'status': instance.status,
  'statusName': instance.statusName,
  'platform': instance.platform,
  'platformName': instance.platformName,
  'trainerId': instance.trainerId,
  'trainerName': instance.trainerName,
  'isPaid': instance.isPaid,
  'price': instance.price,
  'maxParticipants': instance.maxParticipants,
  'enrolledParticipantCount': instance.enrolledParticipantCount,
  'createdAt': instance.createdAt,
};
