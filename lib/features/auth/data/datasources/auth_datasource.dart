import '../models/http/auth_request.dart';
import '../models/http/auth_response.dart';
import '../models/user_model.dart';

abstract class AuthDatasource {
  Future<AuthResponse> login(AuthRequest request);
  Future<AuthResponse> register(AuthRequest request);
  Future<UserModel> getProfile(int userId);
  Future<void> logout();
}