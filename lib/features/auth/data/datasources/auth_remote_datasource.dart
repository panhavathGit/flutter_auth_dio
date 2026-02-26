import 'auth_datasource.dart';
import '../models/http/auth_request.dart';
import '../models/http/auth_response.dart';
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
    final response = await _dioClient.dio.post(
      ApiConfig.register, 
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<UserModel> getProfile(int userId) async {
    final response = await _dioClient.dio.get(
      ApiConfig.profile, // ✅ no userId appended, token auto-attached by AuthInterceptor
    );
    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    // await _dioClient.dio.post(ApiConfig.logout); 
    return;
  }
}