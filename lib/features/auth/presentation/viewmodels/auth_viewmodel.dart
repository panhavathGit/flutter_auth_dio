import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository);

  AuthState _state = AuthState.idle;
  UserModel? _user;
  String? _errorMessage;

  AuthState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.loading;

  Future<bool> login(String email, String password) async {
    _setState(AuthState.loading);
    try {
      _user = await _authRepository.login(email, password);
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
  _setState(AuthState.loading);
  try {
    _user = await _authRepository.register(name, email, password);
    _setState(AuthState.success);
    return true;
  } catch (e) {
    _errorMessage = e.toString();
    _setState(AuthState.error);
    return false;
  }
}

  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    _setState(AuthState.idle);
  }

  Future<void> loadProfile() async {
    _setState(AuthState.loading);
    try {
      _user = await _authRepository.getProfile();
      _setState(AuthState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AuthState.error);
    }
  }

  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }
}
