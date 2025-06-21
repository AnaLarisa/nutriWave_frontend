import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nutriwave_frontend/models/barcode_intake_result.dart';
import 'package:nutriwave_frontend/models/food_intake_result.dart';
import 'package:nutriwave_frontend/models/food_logs_result.dart';
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

  // add food intake
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

// add barcode intake
Future<BarcodeIntakeResult> addBarcodeIntake({required String barcode}) async {
  print('📱 NutritionClient.addBarcodeIntake: Starting with barcode: $barcode');
  
  try {
    final authClient = AuthenticationClient();
    
    if (!authClient.isAuthenticated) {
      return BarcodeIntakeResult.failure(error: 'Please log in to add food items');
    }

    final url = Uri.parse('${Constants.baseUrl}/Nutrients/barcode-intake');
    
    final response = await http.post(
      url,
      headers: {
        ...Constants.defaultHeaders,
        'Authorization': 'Bearer ${authClient.currentToken}',
      },
      body: json.encode(barcode),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Request timed out'),
    );

    print('📱 Response status: ${response.statusCode}');
    print('📱 Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return BarcodeIntakeResult.success(
          message: responseData['message'] ?? 'Food item added successfully',
          foodName: responseData['foodName'],
        );
      } catch (jsonError) {
        return BarcodeIntakeResult.failure(error: 'Invalid response format');
      }
    } else if (response.statusCode == 400) {
      // Handle "Product not found" case
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final errorMessage = errorData['error'] ?? 'Invalid barcode. Please try scanning again';
        return BarcodeIntakeResult.failure(error: errorMessage);
      } catch (jsonError) {
        return BarcodeIntakeResult.failure(error: 'Product not found. This barcode is not in our nutrition database. Try entering the food manually.');
      }
    } else if (response.statusCode == 401) {
      return BarcodeIntakeResult.failure(error: 'Session expired. Please log in again');
    } else if (response.statusCode == 500) {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final errorMessage = errorData['error'] ?? 'Server error occurred. Please try again later.';
        return BarcodeIntakeResult.failure(error: errorMessage);
      } catch (jsonError) {
        return BarcodeIntakeResult.failure(error: 'Server error occurred. Please try again later.');
      }
    } else {
      return BarcodeIntakeResult.failure(
        error: 'Unable to process barcode. Please try scanning again or enter the food manually.'
      );
    }
  } catch (e) {
    print('📱 Exception in addBarcodeIntake: $e');
    if (e.toString().contains('SocketException')) {
      return BarcodeIntakeResult.failure(error: 'No internet connection. Please check your network and try again.');
    } else if (e.toString().contains('timeout')) {
      return BarcodeIntakeResult.failure(error: 'Request timed out. Please try again.');
    } else {
      return BarcodeIntakeResult.failure(error: 'Something went wrong. Please try scanning again or enter the food manually.');
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