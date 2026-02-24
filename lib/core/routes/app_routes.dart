class AppRoutes {
  // This class is not meant to be instantiated or extended; this constructor
  // prevents instantiation and extension.
  AppRoutes._();

  // Auth
  static const String login = 'login';
  static const String register = 'register';

  // Feed 
  static const String main = 'main';
  static const String createTodo = 'createTodo';

  // Profile
  static const String profile = 'profile';

}

class AppPaths {
  AppPaths._();

  // Auth
  static const String login = '/login';
  static const String register = '/register';

  // main nav screen
  static const String createPost = '/create-todo';
  static const String main = '/main';
  static const String profile = '/profile';

}
