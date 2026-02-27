import 'package:json_annotation/json_annotation.dart';
part 'otp_request.g.dart';

@JsonSerializable()
class OtpRequest {
  @JsonKey(name: 'phone')
  final String phoneNumber;
  final bool debug;

  OtpRequest({
    required this.phoneNumber,
    this.debug = true,
  });

  Map <String, dynamic> toJson() => _$OtpRequestToJson(this);

}