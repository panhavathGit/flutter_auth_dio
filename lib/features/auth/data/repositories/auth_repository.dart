import 'package:auth_dio/core/utils/logger.dart';
import 'package:dio/dio.dart';
import '../datasources/auth_datasource.dart';
import '../models/user_model.dart';
import '../models/http/auth_request.dart';
import '../../../../core/services/storage_service.dart';

class AuthRepository {
  final AuthDatasource _datasource; // ← abstract, accepts mock or real
  final StorageService _storageService;

  AuthRepository(this._datasource, this._storageService);

  // Future<UserModel> login(String username, String password) async {
  //   try {
  //     // 1. Create Request
  //     final request = AuthRequest(username: username, password: password);

  //     // 2. Execute Login
  //     final authResponse = await _datasource.login(request);

  //     // 3. Save all credentials to Storage
  //     await _storageService.saveAccessToken(authResponse.accessToken);
  //     await _storageService.saveRefreshToken(authResponse.refreshToken);
  //     await _storageService.saveUserId(authResponse.userId);

  //     // 4. Fetch the full Profile (Hydration)
  //     return await _datasource.getProfile(authResponse.userId);
  //   } on DioException catch (e) {
  //     throw _handleError(e);
  //   }
  // }

  Future<UserModel> login(String username, String password) async {
    try {
      final request = AuthRequest(username: username, password: password);
      final authResponse = await _datasource.login(request);
      await _storageService.saveAccessToken(authResponse.accessToken);
      await _storageService.saveRefreshToken(authResponse.refreshToken);
      await _storageService.saveUserId(authResponse.userId);
      return await _datasource.getProfile(authResponse.userId);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      AppLogger.e('❌ NON-DIO ERROR: $e'); // ← add this
      rethrow;
    }
  }

  Future<UserModel> register(
    String name,
    String username,
    String password,
  ) async {
    try {
      final request = AuthRequest(
        username: username,
        password: password,
      );
      final authResponse = await _datasource.register(request);

      await _storageService.saveAccessToken(authResponse.accessToken);
      await _storageService.saveRefreshToken(authResponse.refreshToken);
      await _storageService.saveUserId(authResponse.userId);

      return await _datasource.getProfile(authResponse.userId);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel?> getProfile() async {
    try {
      final userId = await _storageService.getUserId();
      if (userId == null) return null;

      return await _datasource.getProfile(userId);
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _datasource.logout();
    } finally {
      // Always clear storage even if the API call fails,
      // this because current backend does not have logout, we need to 
      // handle logout directly on client-side (mobile)
      await _storageService.clearAll();
    }
  }

  String _handleError(DioException e) {
    AppLogger.e('DioException type: ${e.type}');
    AppLogger.e('Status code: ${e.response?.statusCode}');
    AppLogger.e('Response data: ${e.response?.data}');
    AppLogger.e('Message: ${e.message}');

    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Check your internet.';
    } else if (e.response?.statusCode == 401) {
      return 'Invalid email or password.';
    }
    return 'Something went wrong. Please try again.';
  }
  
}
