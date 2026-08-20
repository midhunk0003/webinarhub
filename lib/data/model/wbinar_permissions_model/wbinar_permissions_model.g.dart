// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wbinar_permissions_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WbinarPermissionsModel _$WbinarPermissionsModelFromJson(
  Map<String, dynamic> json,
) => WbinarPermissionsModel(
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

Map<String, dynamic> _$WbinarPermissionsModelToJson(
  WbinarPermissionsModel instance,
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
  userId: stringFromJson(json['userId']),
  roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
  rolePermissions:
      (json['rolePermissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  grantedOverrides:
      (json['grantedOverrides'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  deniedOverrides:
      (json['deniedOverrides'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  effectivePermissions:
      (json['effectivePermissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
  'userId': instance.userId,
  'roles': instance.roles,
  'rolePermissions': instance.rolePermissions,
  'grantedOverrides': instance.grantedOverrides,
  'deniedOverrides': instance.deniedOverrides,
  'effectivePermissions': instance.effectivePermissions,
};
