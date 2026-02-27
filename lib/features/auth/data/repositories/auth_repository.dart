import 'package:auth_dio/core/utils/logger.dart';
import 'package:dio/dio.dart';
import '../datasources/auth_datasource.dart';
import '../models/user_model.dart';
import '../models/http/auth/auth_request.dart';
import '../models/http/otp/otp_response.dart'; // Import this
import '../../../../core/services/storage_service.dart';

class AuthRepository {
  final AuthDatasource _datasource;
  final StorageService _storageService;

  AuthRepository(this._datasource, this._storageService);

  // --- NEW: REQUEST OTP ---
  Future<OtpResponse> requestRegisterOtp(String phone) async {
    try {
      // Logic: Tell datasource to hit the v2/auth/request-otp endpoint
      return await _datasource.requestOtp(phone);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      AppLogger.e('❌ NON-DIO ERROR (OTP): $e');
      rethrow;
    }
  }

  // --- UPDATED: REGISTER ---
  Future<UserModel> register({
    required String username,
    required String password,
    required String otp,
  }) async {
    try {
      // 1. Prepare Request with all backend-required fields
      final request = AuthRequest(
        username: username,
        password: password,
        otp: otp,
      );

      // 2. Call Register (v1/auth/register)
      final authResponse = await _datasource.register(request);

      AppLogger.d('📩 REGISTER authResponse: userId=${authResponse.userId}, accessToken=${authResponse.accessToken}, refreshToken=${authResponse.refreshToken}');

      if (authResponse.accessToken == null || authResponse.refreshToken == null || authResponse.userId == null) {
        throw Exception('Register response is missing tokens or userId. Check backend response keys.');
      }

      // 3. Save Tokens
      await _storageService.saveAccessToken(authResponse.accessToken!);
      await _storageService.saveRefreshToken(authResponse.refreshToken!);
      await _storageService.saveUserId(authResponse.userId!);

      // 4. Hydrate User Profile
      return await _datasource.getProfile(authResponse.userId!);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      AppLogger.e('❌ NON-DIO ERROR (REGISTER): $e');
      rethrow;
    }
  }

  // --- LOGIN stays mostly the same ---
  Future<UserModel> login(String username, String password) async {
    try {
      final request = AuthRequest(username: username, password: password);
      final authResponse = await _datasource.login(request);
      
      await _storageService.saveAccessToken(authResponse.accessToken!);
      await _storageService.saveRefreshToken(authResponse.refreshToken!);
      await _storageService.saveUserId(authResponse.userId!);
      
      return await _datasource.getProfile(authResponse.userId!);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      AppLogger.e('❌ NON-DIO ERROR (LOGIN): $e');
      rethrow;
    }
  }

  // --- PROFILE & LOGOUT ---
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
      // Currently backend doesn't have logout endpoint, 
      // but we keep the structure for when they add it.
      await _datasource.logout();
    } catch (_) {
      // Ignore errors if endpoint doesn't exist
    } finally {
      await _storageService.clearAll();
    }
  }

  // --- UPDATED ERROR HANDLING ---
  // String _handleError(DioException e) {
  //   AppLogger.e('DioException: [${e.response?.statusCode}] ${e.requestOptions.path}');
    
  //   // Check if backend sent a specific error message
  //   if (e.response?.data != null && e.response?.data['message'] != null) {
  //     return e.response?.data['message'];
  //   }

  //   if (e.type == DioExceptionType.connectionTimeout) {
  //     return 'Connection timeout. Check your internet.';
  //   } 
    
  //   if (e.response?.statusCode == 401) {
  //     return 'Incorrect credentials or invalid OTP.';
  //   }
    
  //   return 'Something went wrong. Please try again.';
  // }

  String _handleError(DioException e) {
    AppLogger.e('DioException: [${e.response?.statusCode}] ${e.requestOptions.path}');
    AppLogger.e('🔴 Error response body: ${e.response?.data}');

    // ✅ Check both 'message' and 'error' keys (backend uses either)
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message'] ?? data['error'];
      if (msg != null) return msg.toString();
    }

    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Check your internet.';
    }

    if (e.response?.statusCode == 401) {
      return 'Unauthorized. Please check your credentials.';
    }

    return 'Something went wrong. Please try again.';
  }
}