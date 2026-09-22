// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_policy_and_agree_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPolicyAndAgreeModel _$UserPolicyAndAgreeModelFromJson(
  Map<String, dynamic> json,
) => UserPolicyAndAgreeModel(
  statusCode: stringFromJson(json['statusCode']),
  success: stringFromJson(json['success']),
  message: stringFromJson(json['message']),
  errorCode: stringFromJson(json['errorCode']),
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => PolicyAndAgreeList.fromJson(e as Map<String, dynamic>))
          .toList(),
  errors:
      json['errors'] == null
          ? null
          : Errors.fromJson(json['errors'] as Map<String, dynamic>),
  details: stringFromJson(json['details']),
);

Map<String, dynamic> _$UserPolicyAndAgreeModelToJson(
  UserPolicyAndAgreeModel instance,
) => <String, dynamic>{
  'statusCode': instance.statusCode,
  'success': instance.success,
  'message': instance.message,
  'errorCode': instance.errorCode,
  'data': instance.data,
  'errors': instance.errors,
  'details': instance.details,
};

PolicyAndAgreeList _$PolicyAndAgreeListFromJson(Map<String, dynamic> json) =>
    PolicyAndAgreeList(
      id: stringFromJson(json['id']),
      type: stringFromJson(json['type']),
      key: stringFromJson(json['key']),
      title: stringFromJson(json['title']),
      content: stringFromJson(json['content']),
      version: stringFromJson(json['version']),
      isRequired: stringFromJson(json['isRequired']),
      isActive: stringFromJson(json['isActive']),
      effectiveFrom: stringFromJson(json['effectiveFrom']),
    );

Map<String, dynamic> _$PolicyAndAgreeListToJson(PolicyAndAgreeList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'key': instance.key,
      'title': instance.title,
      'content': instance.content,
      'version': instance.version,
      'isRequired': instance.isRequired,
      'isActive': instance.isActive,
      'effectiveFrom': instance.effectiveFrom,
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
