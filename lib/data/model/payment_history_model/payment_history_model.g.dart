// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentHistoryModel _$PaymentHistoryModelFromJson(Map<String, dynamic> json) =>
    PaymentHistoryModel(
      statusCode: stringFromJson(json['statusCode']),
      success: stringFromJson(json['success']),
      message: stringFromJson(json['message']),
      errorCode: stringFromJson(json['errorCode']),
      data:
          json['data'] == null
              ? null
              : Data.fromJson(json['data'] as Map<String, dynamic>),
      errors:
          json['errors'] == null
              ? null
              : Errors.fromJson(json['errors'] as Map<String, dynamic>),
      details: stringFromJson(json['details']),
    );

Map<String, dynamic> _$PaymentHistoryModelToJson(
  PaymentHistoryModel instance,
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
  paymentId: stringFromJson(json['paymentId']),
  webinarId: stringFromJson(json['webinarId']),
  webinarTitle: stringFromJson(json['webinarTitle']),
  amount: stringFromJson(json['amount']),
  currency: stringFromJson(json['currency']),
  status: stringFromJson(json['status']),
  statusName: stringFromJson(json['statusName']),
  paymentMethod: stringFromJson(json['paymentMethod']),
  paymentMethodName: stringFromJson(json['paymentMethodName']),
  gatewayPaymentId: stringFromJson(json['gatewayPaymentId']),
  transactionId: stringFromJson(json['transactionId']),
  paidAt: stringFromJson(json['paidAt']),
  createdAt: stringFromJson(json['createdAt']),
);

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
  'paymentId': instance.paymentId,
  'webinarId': instance.webinarId,
  'webinarTitle': instance.webinarTitle,
  'amount': instance.amount,
  'currency': instance.currency,
  'status': instance.status,
  'statusName': instance.statusName,
  'paymentMethod': instance.paymentMethod,
  'paymentMethodName': instance.paymentMethodName,
  'gatewayPaymentId': instance.gatewayPaymentId,
  'transactionId': instance.transactionId,
  'paidAt': instance.paidAt,
  'createdAt': instance.createdAt,
};

Errors _$ErrorsFromJson(Map<String, dynamic> json) => Errors(
  additionalProp1:
      (json['additionalProp1'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  additionalProp2:
      (json['additionalProp2'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  additionalProp3:
      (json['additionalProp3'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$ErrorsToJson(Errors instance) => <String, dynamic>{
  'additionalProp1': instance.additionalProp1,
  'additionalProp2': instance.additionalProp2,
  'additionalProp3': instance.additionalProp3,
};
