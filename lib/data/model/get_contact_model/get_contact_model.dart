import 'package:json_annotation/json_annotation.dart';
import 'package:lms/core/json_converter.dart';

part 'get_contact_model.g.dart';

@JsonSerializable()
class GetContactModel {
  @JsonKey(fromJson: stringFromJson)
  String? statusCode;

  @JsonKey(fromJson: stringFromJson)
  String? success;

  @JsonKey(fromJson: stringFromJson)
  String? message;

  @JsonKey(fromJson: stringFromJson)
  String? errorCode;

  List<ContactList>? data;

  dynamic errors;
  dynamic details;

  GetContactModel({
    this.statusCode,
    this.success,
    this.message,
    this.errorCode,
    this.data,
    this.errors,
    this.details,
  });

  factory GetContactModel.fromJson(Map<String, dynamic> json) {
    return _$GetContactModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$GetContactModelToJson(this);
}

@JsonSerializable()
class ContactList {
  @JsonKey(fromJson: stringFromJson)
  String? id;

  @JsonKey(fromJson: stringFromJson)
  String? name;

  @JsonKey(fromJson: stringFromJson)
  String? email;

  @JsonKey(fromJson: stringFromJson)
  String? phoneNumber;

  @JsonKey(fromJson: stringFromJson)
  String? address;

  @JsonKey(fromJson: stringFromJson)
  String? description;

  @JsonKey(fromJson: stringFromJson)
  String? createdAt;

  ContactList({
    this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.address,
    this.description,
    this.createdAt,
  });

  factory ContactList.fromJson(Map<String, dynamic> json) =>
      _$ContactListFromJson(json);

  Map<String, dynamic> toJson() => _$ContactListToJson(this);
}
