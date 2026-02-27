import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final int? userId;
  final String? accessToken;
  final String? refreshToken;

  AuthResponse({
    this.userId,
    this.accessToken,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
}