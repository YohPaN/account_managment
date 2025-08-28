import 'package:flutter_dotenv/flutter_dotenv.dart';

class APIConfig {
  static String baseUrl = dotenv.get('BASE_URL', fallback: "10.0.2.2");
  static String port = dotenv.get('PORT', fallback: "8000");
  static String SECRET_API_KEY = dotenv.get('SECRET_API_KEY', fallback: "");
  static String PUSHER_KEY = dotenv.get('PUSHER_KEY', fallback: "");
}
