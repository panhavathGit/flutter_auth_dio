import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Toggle this to switch between mock and real
  static const bool useMock = false;

  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'https://fallback-url.com';
  static const int connectTimeoutSeconds = 10;
  static const int receiveTimeoutSeconds = 10;

}