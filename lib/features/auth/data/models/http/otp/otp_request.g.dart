// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpRequest _$OtpRequestFromJson(Map<String, dynamic> json) => OtpRequest(
  phoneNumber: json['phone'] as String,
  debug: json['debug'] as bool? ?? true,
);

Map<String, dynamic> _$OtpRequestToJson(OtpRequest instance) =>
    <String, dynamic>{'phone': instance.phoneNumber, 'debug': instance.debug};
