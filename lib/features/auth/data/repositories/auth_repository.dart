import 'package:dio/dio.dart';
import '../datasources/auth_datasource.dart';
import '../models/user_model.dart';
import '../../../../core/services/storage_service.dart';

class AuthRepository {
  final AuthDatasource _datasource;   // ← abstract, accepts mock or real
  final StorageService _storageService;

  AuthRepository(this._datasource, this._storageService);

  Future<UserModel> login(String email, String password) async {
    try {
      final user = await _datasource.login(email, password);
      await _storageService.saveToken(user.token);
      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw e.toString(); // catches mock exceptions too
    }
  }

  Future<UserModel> register(String name, String email, String password) async {
    try {
      final user = await _datasource.register(name, email, password);
      await _storageService.saveToken(user.token);
      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel?> getProfile() async {
    try {
      return await _datasource.getProfile();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      throw _handleError(e);
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _datasource.logout();
    } catch (_) {
      // even if logout API fails, clear token locally
    } finally {
      await _storageService.clearToken();
    }
  }

  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Check your internet.';
    } else if (e.response?.statusCode == 401) {
      return 'Invalid email or password.';
    }
    return 'Something went wrong. Please try again.';
  }
}
