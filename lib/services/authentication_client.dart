import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nutriwave_frontend/models/auth_result.dart';
import 'package:nutriwave_frontend/models/login_result.dart';
import '../helpers/constants.dart';

class AuthenticationClient {
  // Singleton pattern for shared access
  static final AuthenticationClient _instance = AuthenticationClient._internal();
  factory AuthenticationClient() => _instance;
  AuthenticationClient._internal();
  String? _currentToken;
  String? get currentToken => _currentToken;
  
  bool get isAuthenticated => _currentToken != null && _currentToken!.isNotEmpty;
  
  void clearToken() {
    _currentToken = null;
  }
  
  // SIGNUP
  Future<AuthResult> createAccount({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required DateTime birthDate,
    required String sex,
  }  ) async {
    try {
      final url = Uri.parse(Constants.createAccountUrl);
      
      final requestBody = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'birthDate': birthDate.toIso8601String(),
        'sex': sex,
      };
      
      final response = await http.post(
        url,
        headers: Constants.defaultHeaders,
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return AuthResult.success(
          message: responseData['message'] ?? 'Account created successfully.',
        );
      } else if (response.statusCode == 400) {
        return AuthResult.failure(
          error: response.body.isNotEmpty 
            ? response.body.replaceAll('"', '') 
            : 'User with this email already exists.',
        );
      } else {
        return AuthResult.failure(
          error: 'Failed to create account. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AuthResult.failure(
        error: 'Network error: ${e.toString()}',
      );
    }
  }
  
  // LOGIN
  Future<LoginResult> login({
    required String email,
    required String password,
  }  ) async {
    try {
      final url = Uri.parse(Constants.loginUrl);
      
      final requestBody = {
        'email': email,
        'password': password,
      };
      
      final response = await http.post(
        url,
        headers: Constants.defaultHeaders,
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 200) {
        final token = response.body.replaceAll('"', '').trim();
        
        _currentToken = token;
        
        return LoginResult.success(token: token);
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        return LoginResult.failure(
          error: responseData['message'] ?? 'Invalid email or password.',
        );
      } else {
        return LoginResult.failure(
          error: 'Login failed. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return LoginResult.failure(
        error: 'Network error: ${e.toString()}',
      );
    }
  }
}
