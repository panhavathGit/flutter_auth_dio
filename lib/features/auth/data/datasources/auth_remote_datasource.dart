import 'package:auth_dio/core/utils/logger.dart';
import 'package:auth_dio/features/auth/data/models/http/otp/otp_request.dart';
import 'package:auth_dio/features/auth/data/models/http/otp/otp_response.dart';

import 'auth_datasource.dart';
import '../models/http/auth/auth_request.dart';
import '../models/http/auth/auth_response.dart';
import '../models/user_model.dart';
import '../../../../core/network/dio_client.dart';
import 'package:auth_dio/core/config/api_config.dart';

/// Receives DioClient via constructor injection

class AuthRemoteDatasource implements AuthDatasource {
  final DioClient _dioClient;

  AuthRemoteDatasource(this._dioClient);

  @override
  Future<AuthResponse> login(AuthRequest request) async {
    final response = await _dioClient.dio.post(
      ApiConfig.login,
      data: request.toJson(), // Uses the generated AuthRequest.toJson()
    );
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<AuthResponse> register(AuthRequest request) async {
    AppLogger.d('📤 REGISTER Request: ${request.toJson()}');
    final response = await _dioClient.dio.post(
      ApiConfig.register,
      data: request.toJson(),
    );
    AppLogger.d('📩 REGISTER Raw Response: ${response.data}');
    AppLogger.d('📩 REGISTER Response Type: ${response.data.runtimeType}');
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<UserModel> getProfile(int userId) async {
    final response = await _dioClient.dio.get(
      ApiConfig.profile, // no userId added, token auto-attached by AuthInterceptor
    );
    return UserModel.fromJson(response.data);
  }

  // @override
  // Future<OtpResponse> requestOtp(String phoneNumber ) async{
  //   final request = OtpRequest(phoneNumber: phoneNumber);
  //   final response = await _dioClient.dio.post(ApiConfig.requestOtp, data: request.toJson() );
  
  //   AppLogger.d('OTP Response: ${response.data}');
    
  //   return OtpResponse.fromJson(response.data);
  // }

    @override
  Future<OtpResponse> requestOtp(String phoneNumber) async {
    final request = OtpRequest(phoneNumber: phoneNumber);
    AppLogger.d('📤 OTP Request body: ${request.toJson()}');
    final response = await _dioClient.dio.post(
      ApiConfig.requestOtp,
      data: request.toJson(),
    );

    AppLogger.d('📩 OTP Raw Response: ${response.data}');
    AppLogger.d('📩 OTP Response Type: ${response.data.runtimeType}');

    // Handle if backend returns plain String
    if (response.data is String) {
      return OtpResponse(message: response.data); // ← wrap string in OtpResponse
    }

    return OtpResponse.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    // await _dioClient.dio.post(ApiConfig.logout); 
    return;
  }
}