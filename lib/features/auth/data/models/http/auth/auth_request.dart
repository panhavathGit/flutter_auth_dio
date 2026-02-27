import 'package:json_annotation/json_annotation.dart';

part 'auth_request.g.dart';

@JsonSerializable(createFactory: false, includeIfNull: false) // We only send this to server, never receive it
class AuthRequest {
  final String username;
  final String password;

  // add this bellow field for user register so we make them nullable
  final String? otp;
  final String? referralCode;
  final String? deviceId;
  final String? firebaseToken;

  const AuthRequest({
    required this.username,
    required this.password,
    this.otp,
    this.referralCode,
    this.deviceId,
    this.firebaseToken
  });

  Map<String, dynamic> toJson() => _$AuthRequestToJson(this);
}