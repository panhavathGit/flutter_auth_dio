import 'package:json_annotation/json_annotation.dart';

part 'auth_request.g.dart';

@JsonSerializable(createFactory: false) // We only send this to server, never receive it
class AuthRequest {
  final String username; // Or email, depending on your login logic
  final String password;

  const AuthRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => _$AuthRequestToJson(this);
}