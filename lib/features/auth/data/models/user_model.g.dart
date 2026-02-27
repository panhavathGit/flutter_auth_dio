// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  fullname: json['fullname'] as String?,
  username: json['username'] as String?,
  phone: json['phone'] as String?,
  dob: json['dob'] as String?,
  gender: json['gender'] as String?,
  address: json['address'] as String?,
  firebaseToken: json['firebaesToken'] as String?,
  createdDate: json['createdDate'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'fullname': instance.fullname,
  'username': instance.username,
  'phone': instance.phone,
  'dob': instance.dob,
  'gender': instance.gender,
  'address': instance.address,
  'firebaesToken': instance.firebaseToken,
  'createdDate': instance.createdDate,
};
