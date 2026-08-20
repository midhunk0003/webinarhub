// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_over_view_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainerOverViewModel _$TrainerOverViewModelFromJson(
  Map<String, dynamic> json,
) => TrainerOverViewModel(
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

Map<String, dynamic> _$TrainerOverViewModelToJson(
  TrainerOverViewModel instance,
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
  totalWebinars: stringFromJson(json['totalWebinars']),
  draftWebinars: stringFromJson(json['draftWebinars']),
  publishedWebinars: stringFromJson(json['publishedWebinars']),
  upcomingWebinars: stringFromJson(json['upcomingWebinars']),
  completedWebinars: stringFromJson(json['completedWebinars']),
  cancelledWebinars: stringFromJson(json['cancelledWebinars']),
  totalParticipants: stringFromJson(json['totalParticipants']),
  materialsUploaded: stringFromJson(json['materialsUploaded']),
  notificationsSent: stringFromJson(json['notificationsSent']),
);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
  'totalWebinars': instance.totalWebinars,
  'draftWebinars': instance.draftWebinars,
  'publishedWebinars': instance.publishedWebinars,
  'upcomingWebinars': instance.upcomingWebinars,
  'completedWebinars': instance.completedWebinars,
  'cancelledWebinars': instance.cancelledWebinars,
  'totalParticipants': instance.totalParticipants,
  'materialsUploaded': instance.materialsUploaded,
  'notificationsSent': instance.notificationsSent,
};
