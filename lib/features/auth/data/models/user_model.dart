import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String fullname;
  final String username;
  final String phone;
  final String? dob;    // Nullable in case the user hasn't set it
  final String? gender; 
  final String? address;

  @JsonKey(name: 'firebaesToken') // Mapping the typo from your backend
  final String? firebaseToken;

  final String? createdDate;

  UserModel({
    required this.id,
    required this.fullname,
    required this.username,
    required this.phone,
    this.dob,
    this.gender,
    this.address,
    this.firebaseToken,
    this.createdDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}