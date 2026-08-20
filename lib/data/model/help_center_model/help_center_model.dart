import 'package:json_annotation/json_annotation.dart';

part 'help_center_model.g.dart';

@JsonSerializable()
class HelpCenterModel {
  bool? status;
  String? message;
  List<HelpCenter>? data;

  HelpCenterModel({this.status, this.message, this.data});

  factory HelpCenterModel.fromJson(Map<String, dynamic> json) {
    return _$HelpCenterModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$HelpCenterModelToJson(this);
}

@JsonSerializable()
class HelpCenter {
  @JsonKey(name: 'category_id')
  int? categoryId;
  @JsonKey(name: 'category_name')
  String? categoryName;
  List<Question>? questions;

  HelpCenter({this.categoryId, this.categoryName, this.questions});

  factory HelpCenter.fromJson(Map<String, dynamic> json) =>
      _$HelpCenterFromJson(json);

  Map<String, dynamic> toJson() => _$HelpCenterToJson(this);
}

@JsonSerializable()
class Question {
  @JsonKey(name: 'question_id')
  int? questionId;
  String? question;
  String? answer;

  Question({this.questionId, this.question, this.answer});

  factory Question.fromJson(Map<String, dynamic> json) {
    return _$QuestionFromJson(json);
  }

  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}
