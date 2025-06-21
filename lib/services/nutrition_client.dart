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

// Add this new result class for food logs
class FoodLogsResult {
  final bool isSuccess;
  final List<String>? foodLogs;
  final String? error;

  FoodLogsResult._({
    required this.isSuccess,
    this.foodLogs,
    this.error,
  });

  factory FoodLogsResult.success({required List<String> foodLogs}) {
    return FoodLogsResult._(isSuccess: true, foodLogs: foodLogs);
  }

  factory FoodLogsResult.failure({required String error}) {
    return FoodLogsResult._(isSuccess: false, error: error);
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

  // Get food logs for a specific date
  Future<FoodLogsResult> getFoodLogs({DateTime? date}) async {
    try {
      final authClient = AuthenticationClient();
      
      if (!authClient.isAuthenticated) {
        return FoodLogsResult.failure(error: 'User not authenticated');
      }

      final selectedDate = date ?? DateTime.now();
      // Format date as YYYY-MM-DD
      final dateString = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      
      print('🍽️ Getting food logs for date: $dateString');
      
      final url = Uri.parse('${Constants.baseUrl}/Nutrients/food-logs?dateTime=${Uri.encodeComponent(dateString)}');
      
      print('🍽️ Food logs URL: $url');
      
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

      print('🍽️ Response status: ${response.statusCode}');
      print('🍽️ Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final List<String> foodLogs = jsonList.map((item) => item.toString()).toList();
        
        return FoodLogsResult.success(foodLogs: foodLogs);
      } else if (response.statusCode == 401) {
        return FoodLogsResult.failure(error: 'Authentication failed');
      } else {
        return FoodLogsResult.failure(
          error: 'Failed to load food logs. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('🍽️ Exception in getFoodLogs: $e');
      if (e.toString().contains('SocketException')) {
        return FoodLogsResult.failure(
          error: 'Network error: Cannot connect to server',
        );
      } else if (e.toString().contains('timeout')) {
        return FoodLogsResult.failure(
          error: 'Request timeout: Server is taking too long to respond',
        );
      } else {
        return FoodLogsResult.failure(
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
        return FoodIntakeResult.failure(error: 'Please log in to add food items');
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
        return FoodIntakeResult.failure(error: 'Session expired. Please log in again');
      } else if (response.statusCode == 400) {
        return FoodIntakeResult.failure(error: 'Invalid food description. Please provide more details');
      } else if (response.statusCode == 500) {
        return FoodIntakeResult.failure(error: 'Server error. Please try again later');
      } else {
        return FoodIntakeResult.failure(error: 'Unable to add food item. Please try again');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        return FoodIntakeResult.failure(error: 'No internet connection. Please check your network');
      } else if (e.toString().contains('timeout')) {
        return FoodIntakeResult.failure(error: 'Request timeout. Please try again');
      } else {
        return FoodIntakeResult.failure(error: 'Something went wrong. Please try again');
      }
    }
  }

  // Remove food intake
  Future<FoodIntakeResult> removeFoodIntake({required String description}) async {
    try {
      final authClient = AuthenticationClient();
      
      if (!authClient.isAuthenticated) {
        return FoodIntakeResult.failure(error: 'Please log in to remove food items');
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
        return FoodIntakeResult.failure(error: 'Session expired. Please log in again');
      } else if (response.statusCode == 404) {
        return FoodIntakeResult.failure(error: 'Food item not found or already removed');
      } else if (response.statusCode == 500) {
        return FoodIntakeResult.failure(error: 'Server error. Please try again later');
      } else {
        return FoodIntakeResult.failure(error: 'Unable to remove food item. Please try again');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        return FoodIntakeResult.failure(error: 'No internet connection. Please check your network');
      } else if (e.toString().contains('timeout')) {
        return FoodIntakeResult.failure(error: 'Request timeout. Please try again');
      } else {
        return FoodIntakeResult.failure(error: 'Something went wrong. Please try again');
      }
    }
  }
}