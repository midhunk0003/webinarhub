// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginModel _$LoginModelFromJson(Map<String, dynamic> json) => LoginModel(
  statusCode: (json['statusCode'] as num?)?.toInt(),
  success: json['success'] as bool?,
  message: stringFromJson(json['message']),
  data:
      json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
  errors: json['errors'],
  details: json['details'],
);

Map<String, dynamic> _$LoginModelToJson(LoginModel instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'errors': instance.errors,
      'details': instance.details,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
  accessToken: stringFromJson(json['accessToken']),
  refreshToken: stringFromJson(json['refreshToken']),
  accessTokenExpiry: stringFromJson(json['accessTokenExpiry']),
  user:
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'accessTokenExpiry': instance.accessTokenExpiry,
  'user': instance.user,
};

User _$UserFromJson(Map<String, dynamic> json) => User(
  userId: stringFromJson(json['userId']),
  email: stringFromJson(json['email']),
  username: stringFromJson(json['username']),
  fullName: stringFromJson(json['fullName']),
  status: stringFromJson(json['status']),
  role: stringFromJson(json['role']),
  mustChangePassword: stringFromJson(json['mustChangePassword']),
  lastLoginAt: stringFromJson(json['lastLoginAt']),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'userId': instance.userId,
  'email': instance.email,
  'username': instance.username,
  'fullName': instance.fullName,
  'status': instance.status,
  'role': instance.role,
  'mustChangePassword': instance.mustChangePassword,
  'lastLoginAt': instance.lastLoginAt,
};
