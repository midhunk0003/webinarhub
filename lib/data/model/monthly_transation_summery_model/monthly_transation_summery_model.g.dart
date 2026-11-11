// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_transation_summery_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonthlyTransationSummeryModel _$MonthlyTransationSummeryModelFromJson(
  Map<String, dynamic> json,
) => MonthlyTransationSummeryModel(
  statusCode: stringFromJson(json['statusCode']),
  success: stringFromJson(json['success']),
  message: stringFromJson(json['message']),
  errorCode: stringFromJson(json['errorCode']),
  data:
      (json['data'] as List<dynamic>?)
          ?.map(
            (e) => MonthlySummeryDataList.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
  errors: stringFromJson(json['errors']),
  details: stringFromJson(json['details']),
);

Map<String, dynamic> _$MonthlyTransationSummeryModelToJson(
  MonthlyTransationSummeryModel instance,
) => <String, dynamic>{
  'statusCode': instance.statusCode,
  'success': instance.success,
  'message': instance.message,
  'errorCode': instance.errorCode,
  'data': instance.data,
  'errors': instance.errors,
  'details': instance.details,
};

MonthlySummeryDataList _$MonthlySummeryDataListFromJson(
  Map<String, dynamic> json,
) => MonthlySummeryDataList(
  year: stringFromJson(json['year']),
  month: stringFromJson(json['month']),
  monthName: stringFromJson(json['monthName']),
  totalAmount: stringFromJson(json['totalAmount']),
  totalSuccessfulPayments: stringFromJson(json['totalSuccessfulPayments']),
  currency: stringFromJson(json['currency']),
);

Map<String, dynamic> _$MonthlySummeryDataListToJson(
  MonthlySummeryDataList instance,
) => <String, dynamic>{
  'year': instance.year,
  'month': instance.month,
  'monthName': instance.monthName,
  'totalAmount': instance.totalAmount,
  'totalSuccessfulPayments': instance.totalSuccessfulPayments,
  'currency': instance.currency,
};
