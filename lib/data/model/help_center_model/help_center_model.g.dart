// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'help_center_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HelpCenterModel _$HelpCenterModelFromJson(Map<String, dynamic> json) =>
    HelpCenterModel(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => HelpCenter.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$HelpCenterModelToJson(HelpCenterModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };

HelpCenter _$HelpCenterFromJson(Map<String, dynamic> json) => HelpCenter(
  categoryId: (json['category_id'] as num?)?.toInt(),
  categoryName: json['category_name'] as String?,
  questions:
      (json['questions'] as List<dynamic>?)
          ?.map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$HelpCenterToJson(HelpCenter instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'category_name': instance.categoryName,
      'questions': instance.questions,
    };

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
  questionId: (json['question_id'] as num?)?.toInt(),
  question: json['question'] as String?,
  answer: json['answer'] as String?,
);

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
  'question_id': instance.questionId,
  'question': instance.question,
  'answer': instance.answer,
};
