import '../models/http/auth/auth_request.dart';
import '../models/http/auth/auth_response.dart';
import '../models/user_model.dart';
import '../models/http/otp/otp_response.dart';

abstract class AuthDatasource {
  Future<AuthResponse> login(AuthRequest request);
  Future<AuthResponse> register(AuthRequest request);
  Future<OtpResponse> requestOtp(String phone);
  Future<UserModel> getProfile(int userId);
  Future<void> logout();
}