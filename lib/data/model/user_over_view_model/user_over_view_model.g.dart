// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_over_view_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserOverViewModel _$UserOverViewModelFromJson(Map<String, dynamic> json) =>
    UserOverViewModel(
      statusCode: stringFromJson(json['statusCode']),
      success: stringFromJson(json['success']),
      message: stringFromJson(json['message']),
      errorCode: stringFromJson(json['errorCode']),
      data:
          json['data'] == null
              ? null
              : Data.fromJson(json['data'] as Map<String, dynamic>),
      errors: json['errors'],
      details: json['details'],
    );

Map<String, dynamic> _$UserOverViewModelToJson(UserOverViewModel instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'success': instance.success,
      'message': instance.message,
      'errorCode': instance.errorCode,
      'data': instance.data,
      'errors': instance.errors,
      'details': instance.details,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
  upcomingWebinarsCount: stringFromJson(json['upcomingWebinarsCount']),
  pastWebinarsCount: stringFromJson(json['pastWebinarsCount']),
  totalMaterialsAvailable: stringFromJson(json['totalMaterialsAvailable']),
  unreadNotificationsCount: stringFromJson(json['unreadNotificationsCount']),
  totalSuccessfulPayments: stringFromJson(json['totalSuccessfulPayments']),
  totalAmountSpent: stringFromJson(json['totalAmountSpent']),
);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
  'upcomingWebinarsCount': instance.upcomingWebinarsCount,
  'pastWebinarsCount': instance.pastWebinarsCount,
  'totalMaterialsAvailable': instance.totalMaterialsAvailable,
  'unreadNotificationsCount': instance.unreadNotificationsCount,
  'totalSuccessfulPayments': instance.totalSuccessfulPayments,
  'totalAmountSpent': instance.totalAmountSpent,
};
