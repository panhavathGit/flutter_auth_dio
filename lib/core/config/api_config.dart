class ApiConfig {
  ApiConfig._();

  // Auth
  static const String login = 'customer/api/v1/auth/login';
  static const String register = 'customer/api/v1/auth/register';
  static const String requestOTP = 'customer/api/v1/auth/request-otp';
  static const String refreshToken = 'customer/api/v1/auth/token';
  static const String logout = 'auth/logout';

  // Profile
  static const String profile = '/customer/api/v1/profile/detail';

  // Todo
  static const String todos = 'todos';
  static String todoById(String id) => 'todos/$id';
}