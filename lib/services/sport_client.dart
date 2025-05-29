import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helpers/constants.dart';
import '../services/authentication_client.dart';
import '../models/sport_log_dto.dart';

class SportLogsResult {
  final bool isSuccess;
  final List<SportLogDto>? sportLogs;
  final String? error;

  SportLogsResult._({
    required this.isSuccess,
    this.sportLogs,
    this.error,
  });

  factory SportLogsResult.success({required List<SportLogDto> sportLogs}) {
    return SportLogsResult._(isSuccess: true, sportLogs: sportLogs);
  }

  factory SportLogsResult.failure({required String error}) {
    return SportLogsResult._(isSuccess: false, error: error);
  }
}

class SportIntakeResult {
  final bool isSuccess;
  final String? message;
  final String? error;

  SportIntakeResult._({
    required this.isSuccess,
    this.message,
    this.error,
  });

  factory SportIntakeResult.success({String? message}) {
    return SportIntakeResult._(isSuccess: true, message: message);
  }

  factory SportIntakeResult.failure({required String error}) {
    return SportIntakeResult._(isSuccess: false, error: error);
  }
}

class SportClient {
  // Singleton pattern
  static final SportClient _instance = SportClient._internal();
  factory SportClient() => _instance;
  SportClient._internal();

  // Get sport logs for a specific date
  Future<SportLogsResult> getSportLogs({DateTime? date}) async {
    try {
      final authClient = AuthenticationClient();
      
      if (!authClient.isAuthenticated) {
        return SportLogsResult.failure(error: 'User not authenticated');
      }

      final selectedDate = date ?? DateTime.now();
      // Format date as YYYY-MM-DD
      final dateString = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      
      print('🏃 Getting sport logs for date: $dateString');
      
      final url = Uri.parse('${Constants.baseUrl}/Sport/api/sport-logs?dateTime=${Uri.encodeComponent(dateString)}');
      
      print('🏃 Sport logs URL: $url');
      
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

      print('🏃 Response status: ${response.statusCode}');
      print('🏃 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final List<SportLogDto> sportLogs = jsonList
            .map((json) => SportLogDto.fromJson(json))
            .toList();
        
        return SportLogsResult.success(sportLogs: sportLogs);
      } else if (response.statusCode == 401) {
        return SportLogsResult.failure(error: 'Authentication failed');
      } else {
        return SportLogsResult.failure(
          error: 'Failed to load sport logs. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('🏃 Exception in getSportLogs: $e');
      if (e.toString().contains('SocketException')) {
        return SportLogsResult.failure(
          error: 'Network error: Cannot connect to server',
        );
      } else if (e.toString().contains('timeout')) {
        return SportLogsResult.failure(
          error: 'Request timeout: Server is taking too long to respond',
        );
      } else {
        return SportLogsResult.failure(
          error: 'Error: ${e.toString()}',
        );
      }
    }
  }

  // Add sport intake
  Future<SportIntakeResult> addSportIntake({required String description}) async {
    try {
      final authClient = AuthenticationClient();
      
      if (!authClient.isAuthenticated) {
        return SportIntakeResult.failure(error: 'User not authenticated');
      }

      final url = Uri.parse('${Constants.baseUrl}/Sport/api/sport-intake');
      
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
        return SportIntakeResult.success(
          message: response.body.replaceAll('"', ''),
        );
      } else if (response.statusCode == 401) {
        return SportIntakeResult.failure(error: 'Authentication failed');
      } else {
        return SportIntakeResult.failure(
          error: 'Failed to add sport. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return SportIntakeResult.failure(error: 'Error: ${e.toString()}');
    }
  }

  // Remove sport intake
  Future<SportIntakeResult> removeSportIntake({required String description}) async {
    try {
      final authClient = AuthenticationClient();
      
      if (!authClient.isAuthenticated) {
        return SportIntakeResult.failure(error: 'User not authenticated');
      }

      final url = Uri.parse('${Constants.baseUrl}/Sport/api/sport-intake');
      
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
        return SportIntakeResult.success(
          message: response.body.replaceAll('"', ''),
        );
      } else if (response.statusCode == 401) {
        return SportIntakeResult.failure(error: 'Authentication failed');
      } else {
        return SportIntakeResult.failure(
          error: 'Failed to remove sport. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return SportIntakeResult.failure(error: 'Error: ${e.toString()}');
    }
  }
}