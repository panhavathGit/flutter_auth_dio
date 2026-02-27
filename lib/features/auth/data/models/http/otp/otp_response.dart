import 'package:json_annotation/json_annotation.dart';
part 'otp_response.g.dart';

@JsonSerializable()
class OtpResponse {
  final String? otp; // Debug mode returns this
  final String message;

  OtpResponse({this.otp, required this.message});

  factory OtpResponse.fromJson(Map<String, dynamic> json) => _$OtpResponseFromJson(json);
}