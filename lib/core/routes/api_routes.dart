class ApiRoutes {
  ApiRoutes._();

  // Auth
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String profile = 'auth/profile';
  static const String logout = 'auth/logout';

  // Todo
  static const String todos = 'todos';
  static String todoById(String id) => 'todos/$id';
}