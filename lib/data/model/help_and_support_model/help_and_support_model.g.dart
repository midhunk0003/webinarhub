// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'help_and_support_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HelpAndSupportModel _$HelpAndSupportModelFromJson(Map<String, dynamic> json) =>
    HelpAndSupportModel(
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

Map<String, dynamic> _$HelpAndSupportModelToJson(
  HelpAndSupportModel instance,
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
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
  'categories': instance.categories,
};

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: stringFromJson(json['id']),
  name: stringFromJson(json['name']),
  slug: stringFromJson(json['slug']),
  displayOrder: stringFromJson(json['displayOrder']),
  faqs:
      (json['faqs'] as List<dynamic>?)
          ?.map((e) => Faq.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
  'displayOrder': instance.displayOrder,
  'faqs': instance.faqs,
};

Faq _$FaqFromJson(Map<String, dynamic> json) => Faq(
  id: stringFromJson(json['id']),
  question: stringFromJson(json['question']),
  answer: stringFromJson(json['answer']),
  displayOrder: stringFromJson(json['displayOrder']),
);

Map<String, dynamic> _$FaqToJson(Faq instance) => <String, dynamic>{
  'id': instance.id,
  'question': instance.question,
  'answer': instance.answer,
  'displayOrder': instance.displayOrder,
};
