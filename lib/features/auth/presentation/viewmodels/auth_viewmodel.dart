import 'package:auth_dio/core/utils/logger.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthState { idle, loading, success, error, otpSent }

class AuthViewModel extends ChangeNotifier {

  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository);

  AuthState _state = AuthState.idle;
  UserModel? _user;
  String? _errorMessage;
  String? _generatedOtp; // 2. To hold the OTP for your SnackBar

  AuthState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get generatedOtp => _generatedOtp; 
  bool get isLoading => _state == AuthState.loading;

  // --- STEP 1: REQUEST OTP ---
  Future<void> requestOtp(String phone) async {
    _errorMessage = null;
    _setState(AuthState.loading);
    try {
      final response = await _authRepository.requestRegisterOtp(phone);
      _generatedOtp = response.otp; // Capture the code from backend debug mode
      _setState(AuthState.otpSent); // Switch UI to Step 2
    } catch (e) {
      AppLogger.e('OTP REQUEST ERROR: $e');
      _errorMessage = e.toString();
      _setState(AuthState.error);
    }
  }

  // --- STEP 2: COMPLETE REGISTER ---
  // Updated signature to include 'otp'
  Future<bool> register({
    required String username, 
    required String password, 
    required String otp,
  }) async {
    _errorMessage = null;
    _setState(AuthState.loading);
    try {
      // The repository handles the expanded AuthRequest now
      _user = await _authRepository.register(
        username: username,
        password: password,
        otp: otp,
      );
      _setState(AuthState.success);
      return true;
    } catch (e) {
      AppLogger.e('REGISTER ERROR: $e');
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return false;
    }
  }
  
  Future<bool> login(String username, String password) async {
    _errorMessage = null;
    _setState(AuthState.loading);
    try {
      _user = await _authRepository.login(username, password);
      _setState(AuthState.success);
      return true;
    } catch (e) {
      AppLogger.e('LOGIN ERROR: $e'); 
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    _errorMessage = null;
    _setState(AuthState.idle);
  }

  Future<void> loadProfile() async {
    _setState(AuthState.loading);
    try {
      _user = await _authRepository.getProfile();
      if (_user != null) {
        _setState(AuthState.success);
      } else {
        _setState(AuthState.idle);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AuthState.error);
    }
  }

  // --- UTILS ---
  // Call this if the user wants to go back and change their phone number
  void resetToIdle() {
    _state = AuthState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }
}