
class Constants {
  // Base URL
  static const String baseUrl = 'http://192.168.43.82:5000'; // and change ip to localhost if testing from emulator
  
  // API Endpoints
  static const String createAccountEndpoint = '/Authentication/CreateAccount';
  static const String loginEndpoint = '/Authentication/Login';
  
  // Full URLs
  static const String createAccountUrl = '$baseUrl$createAccountEndpoint';
  static const String loginUrl = '$baseUrl$loginEndpoint';
  
  // HTTP Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Authorization header helper
  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}