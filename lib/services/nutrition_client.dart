import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helpers/constants.dart';
import '../services/authentication_client.dart';
import '../models/nutrient_status.dart';

class NutritionResult {
  final bool isSuccess;
  final List<NutrientStatus>? nutrition;
  final String? error;

  NutritionResult._({
    required this.isSuccess,
    this.nutrition,
    this.error,
  });

  factory NutritionResult.success({required List<NutrientStatus> nutrition}) {
    return NutritionResult._(isSuccess: true, nutrition: nutrition);
  }

  factory NutritionResult.failure({required String error}) {
    return NutritionResult._(isSuccess: false, error: error);
  }
}

class FoodIntakeResult {
  final bool isSuccess;
  final String? message;
  final String? error;

  FoodIntakeResult._({
    required this.isSuccess,
    this.message,
    this.error,
  });

  factory FoodIntakeResult.success({String? message}) {
    return FoodIntakeResult._(isSuccess: true, message: message);
  }

  factory FoodIntakeResult.failure({required String error}) {
    return FoodIntakeResult._(isSuccess: false, error: error);
  }
}

class NutritionClient {
  // Singleton pattern
  static final NutritionClient _instance = NutritionClient._internal();
  factory NutritionClient() => _instance;
  NutritionClient._internal();

  // Get nutrition data for a specific date
  Future<NutritionResult> getAllNutrition({DateTime? date}) async {
    try {
      final authClient = AuthenticationClient();
      
      if (!authClient.isAuthenticated) {
        return NutritionResult.failure(error: 'User not authenticated');
      }

      final selectedDate = date ?? DateTime.now();
      // Format date as YYYY-MM-DD (your C# API likely expects this format)
      final dateString = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      
      print('🔍 Sending date parameter: $dateString');
      
      final url = Uri.parse('${Constants.baseUrl}/Nutrients/allNutrition?dateTime=${Uri.encodeComponent(dateString)}');
      
      print('🔍 Full URL: $url');
      
      final response = await http.get(
        url,
        headers: {
          ...Constants.defaultHeaders,
          'Authorization': 'Bearer ${authClient.currentToken}',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timed out'),
      );

      print('🔍 Response status: ${response.statusCode}');
      print('🔍 Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final List<NutrientStatus> nutrition = jsonList
            .map((json) => NutrientStatus.fromJson(json))
            .toList();
        
        return NutritionResult.success(nutrition: nutrition);
      } else if (response.statusCode == 401) {
        return NutritionResult.failure(error: 'Authentication failed');
      } else {
        return NutritionResult.failure(
          error: 'Failed to load nutrition data. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('🔍 Exception in getAllNutrition: $e');
      if (e.toString().contains('SocketException')) {
        return NutritionResult.failure(
          error: 'Network error: Cannot connect to server',
        );
      } else if (e.toString().contains('timeout')) {
        return NutritionResult.failure(
          error: 'Request timeout: Server is taking too long to respond',
        );
      } else {
        return NutritionResult.failure(
          error: 'Error: ${e.toString()}',
        );
      }
    }
  }

  // Add food intake
  Future<FoodIntakeResult> addFoodIntake({required String description}) async {
    try {
      final authClient = AuthenticationClient();
      
      if (!authClient.isAuthenticated) {
        return FoodIntakeResult.failure(error: 'User not authenticated');
      }

      final url = Uri.parse('${Constants.baseUrl}/Nutrients/food-intake');
      
      final response = await http.post(
        url,
        headers: {
          ...Constants.defaultHeaders,
          'Authorization': 'Bearer ${authClient.currentToken}',
        },
        body: json.encode(description),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timed out'),
      );

      if (response.statusCode == 200) {
        return FoodIntakeResult.success(
          message: response.body.replaceAll('"', ''),
        );
      } else if (response.statusCode == 401) {
        return FoodIntakeResult.failure(error: 'Authentication failed');
      } else {
        return FoodIntakeResult.failure(
          error: 'Failed to add food. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return FoodIntakeResult.failure(error: 'Error: ${e.toString()}');
    }
  }

  // Remove food intake
  Future<FoodIntakeResult> removeFoodIntake({required String description}) async {
    try {
      final authClient = AuthenticationClient();
      
      if (!authClient.isAuthenticated) {
        return FoodIntakeResult.failure(error: 'User not authenticated');
      }

      final url = Uri.parse('${Constants.baseUrl}/Nutrients/food-intake');
      
      final response = await http.delete(
        url,
        headers: {
          ...Constants.defaultHeaders,
          'Authorization': 'Bearer ${authClient.currentToken}',
        },
        body: json.encode(description),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timed out'),
      );

      if (response.statusCode == 200) {
        return FoodIntakeResult.success(
          message: response.body.replaceAll('"', ''),
        );
      } else if (response.statusCode == 401) {
        return FoodIntakeResult.failure(error: 'Authentication failed');
      } else {
        return FoodIntakeResult.failure(
          error: 'Failed to remove food. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return FoodIntakeResult.failure(error: 'Error: ${e.toString()}');
    }
  }
}