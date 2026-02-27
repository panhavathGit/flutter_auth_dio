// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpResponse _$OtpResponseFromJson(Map<String, dynamic> json) => OtpResponse(
  otp: json['otp'] as String?,
  message: json['message'] as String,
);

Map<String, dynamic> _$OtpResponseToJson(OtpResponse instance) =>
    <String, dynamic>{'otp': instance.otp, 'message': instance.message};
