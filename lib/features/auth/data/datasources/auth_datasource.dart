import '../models/user_model.dart';

/// Defines what auth operations exist, not how they work

abstract class AuthDatasource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<UserModel?> getProfile();
  Future<void> logout();
}