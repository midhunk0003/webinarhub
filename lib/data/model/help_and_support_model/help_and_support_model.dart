import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'help_and_support_model.g.dart';

@JsonSerializable()
class HelpAndSupportModel {
  @JsonKey(fromJson: stringFromJson)
  String? statusCode;

  @JsonKey(fromJson: stringFromJson)
  String? success;

  @JsonKey(fromJson: stringFromJson)
  String? message;

  @JsonKey(fromJson: stringFromJson)
  String? errorCode;

  Data? data;

  @JsonKey(fromJson: stringFromJson)
  String? errors;

  @JsonKey(fromJson: stringFromJson)
  String? details;

  HelpAndSupportModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory HelpAndSupportModel.fromJson(Map<String, dynamic> json) =>
      _$HelpAndSupportModelFromJson(json);

  Map<String, dynamic> toJson() => _$HelpAndSupportModelToJson(this);
}

@JsonSerializable()
class Data {
  List<Category>? categories;

  Data({this.categories});

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}

@JsonSerializable()
class Category {
  @JsonKey(fromJson: stringFromJson)
  String? id;

  @JsonKey(fromJson: stringFromJson)
  String? name;

  @JsonKey(fromJson: stringFromJson)
  String? slug;

  @JsonKey(fromJson: stringFromJson)
  String? displayOrder;

  List<Faq>? faqs;

  Category({this.id, this.name, this.slug, this.displayOrder, this.faqs});

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class Faq {
  @JsonKey(fromJson: stringFromJson)
  String? id;

  @JsonKey(fromJson: stringFromJson)
  String? question;

  @JsonKey(fromJson: stringFromJson)
  String? answer;

  @JsonKey(fromJson: stringFromJson)
  String? displayOrder;

  Faq({this.id, this.question, this.answer, this.displayOrder});

  factory Faq.fromJson(Map<String, dynamic> json) => _$FaqFromJson(json);

  Map<String, dynamic> toJson() => _$FaqToJson(this);
}
