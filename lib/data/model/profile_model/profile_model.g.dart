// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
  statusCode: (json['statusCode'] as num?)?.toInt(),
  success: json['success'] as bool?,
  message: stringFromJson(json['message']),
  errorCode: stringFromJson(json['errorCode']),
  data:
      json['data'] == null
          ? null
          : ProfileData.fromJson(json['data'] as Map<String, dynamic>),
  errors:
      json['errors'] == null
          ? null
          : Errors.fromJson(json['errors'] as Map<String, dynamic>),
  details: stringFromJson(json['details']),
);

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'success': instance.success,
      'message': instance.message,
      'errorCode': instance.errorCode,
      'data': instance.data,
      'errors': instance.errors,
      'details': instance.details,
    };

ProfileData _$ProfileDataFromJson(Map<String, dynamic> json) => ProfileData(
  userId: stringFromJson(json['userId']),
  email: stringFromJson(json['email']),
  username: stringFromJson(json['username']),
  firstName: stringFromJson(json['firstName']),
  lastName: stringFromJson(json['lastName']),
  fullName: stringFromJson(json['fullName']),
  phoneNumber: stringFromJson(json['phoneNumber']),
  profileImageUrl: stringFromJson(json['profileImageUrl']),
  status: stringFromJson(json['status']),
  role: stringFromJson(json['role']),
  isEmailConfirmed: stringFromJson(json['isEmailConfirmed']),
  createdAt: stringFromJson(json['createdAt']),
  lastLoginAt: stringFromJson(json['lastLoginAt']),
);

Map<String, dynamic> _$ProfileDataToJson(ProfileData instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'username': instance.username,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'fullName': instance.fullName,
      'phoneNumber': instance.phoneNumber,
      'profileImageUrl': instance.profileImageUrl,
      'status': instance.status,
      'role': instance.role,
      'isEmailConfirmed': instance.isEmailConfirmed,
      'createdAt': instance.createdAt,
      'lastLoginAt': instance.lastLoginAt,
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
