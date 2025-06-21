import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:5000';
  
  static const String createAccountEndpoint = '/Authentication/CreateAccount';
  static const String loginEndpoint = '/Authentication/Login';
  
  static String get createAccountUrl => '$baseUrl$createAccountEndpoint';
  static String get loginUrl => '$baseUrl$loginEndpoint';
  
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
  
  static int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30') ?? 30;
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
}