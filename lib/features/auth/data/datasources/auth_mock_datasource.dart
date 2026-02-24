import 'auth_datasource.dart';
import '../models/user_model.dart';

class AuthMockDatasource implements AuthDatasource {
  Future<void> _delay() =>
      Future.delayed(const Duration(seconds: 1));

  @override
  Future<UserModel> login(String email, String password) async {
    await _delay();
    if (password != '123456') {
      throw Exception('Invalid email or password.');
    }
    return UserModel(
      id: '1',
      name: 'Mock User',
      email: email,
      token: 'mock_token_abc123',
    );
  }

  @override
  Future<UserModel> register(
      String name, String email, String password) async {
    await _delay();
    return UserModel(
      id: '2',
      name: name,
      email: email,
      token: 'mock_token_xyz789',
    );
  }

  @override
  Future<UserModel?> getProfile() async {
    await _delay();
    return UserModel(
      id: '1',
      name: 'Mock User',
      email: 'mock@example.com',
      token: 'mock_token_abc123',
    );
  }

  @override
  Future<void> logout() async {
    await _delay();
  }
}