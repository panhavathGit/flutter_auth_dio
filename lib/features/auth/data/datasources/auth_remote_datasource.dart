import 'auth_datasource.dart';
import '../models/user_model.dart';
import '../../../../core/network/dio_client.dart';
import 'package:auth_dio/core/routes/api_routes.dart';

/// Receives DioClient via constructor injection

class AuthRemoteDatasource implements AuthDatasource {
  final DioClient _dioClient;

  AuthRemoteDatasource(this._dioClient);

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await _dioClient.dio.post(
      ApiRoutes.login,
      data: {'email': email, 'password': password},
    );
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    final response = await _dioClient.dio.post(
      ApiRoutes.register, 
      data: {'name': name, 'email': email, 'password': password},
    );
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel?> getProfile() async {
    final response = await _dioClient.dio.get(ApiRoutes.profile); 
    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    await _dioClient.dio.post(ApiRoutes.logout); 
  }

}