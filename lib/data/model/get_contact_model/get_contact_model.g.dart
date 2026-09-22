// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_contact_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetContactModel _$GetContactModelFromJson(Map<String, dynamic> json) =>
    GetContactModel(
      statusCode: stringFromJson(json['statusCode']),
      success: stringFromJson(json['success']),
      message: stringFromJson(json['message']),
      errorCode: stringFromJson(json['errorCode']),
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => ContactList.fromJson(e as Map<String, dynamic>))
              .toList(),
      errors: json['errors'],
      details: json['details'],
    );

Map<String, dynamic> _$GetContactModelToJson(GetContactModel instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'success': instance.success,
      'message': instance.message,
      'errorCode': instance.errorCode,
      'data': instance.data,
      'errors': instance.errors,
      'details': instance.details,
    };

ContactList _$ContactListFromJson(Map<String, dynamic> json) => ContactList(
  id: stringFromJson(json['id']),
  name: stringFromJson(json['name']),
  email: stringFromJson(json['email']),
  phoneNumber: stringFromJson(json['phoneNumber']),
  address: stringFromJson(json['address']),
  description: stringFromJson(json['description']),
  createdAt: stringFromJson(json['createdAt']),
);

Map<String, dynamic> _$ContactListToJson(ContactList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'address': instance.address,
      'description': instance.description,
      'createdAt': instance.createdAt,
    };
