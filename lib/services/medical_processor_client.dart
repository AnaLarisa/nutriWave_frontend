import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../helpers/constants.dart';
import '../services/authentication_client.dart';
import '../models/medical_processor_result.dart';

class MedicalProcessorClient {
  // Singleton pattern
  static final MedicalProcessorClient _instance = MedicalProcessorClient._internal();
  factory MedicalProcessorClient() => _instance;
  MedicalProcessorClient._internal();

  // Process PDF file
  Future<MedicalProcessorResult> processPdf({required File pdfFile}) async {
    try {
      final authClient = AuthenticationClient();
      
      if (!authClient.isAuthenticated) {
        return MedicalProcessorResult.failure(error: 'User not authenticated');
      }

      // Validate file extension
      if (!pdfFile.path.toLowerCase().endsWith('.pdf')) {
        return MedicalProcessorResult.failure(error: 'File must be a PDF');
      }

      // Check if file exists
      if (!await pdfFile.exists()) {
        return MedicalProcessorResult.failure(error: 'File does not exist');
      }

      final url = Uri.parse('${Constants.baseUrl}/api/MedicalProcessor/process-pdf');
      
      // Create multipart request
      var request = http.MultipartRequest('POST', url);
      
      request.headers.addAll({
        'Authorization': 'Bearer ${authClient.currentToken}',
        'Accept': 'application/json',
      });
      
      print('🔍 Request headers: ${request.headers}');
      
      // Add file to request
      var multipartFile = await http.MultipartFile.fromPath(
        'pdfFile', // This should match the parameter name in your controller
        pdfFile.path,
      );
      request.files.add(multipartFile);
      
      // Send request with extended timeout since processing might take a while
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 5), // 5 minutes timeout for PDF processing
        onTimeout: () => throw Exception('Request timed out - PDF processing took too long'),
      );
      
      // Convert streamed response to regular response
      final response = await http.Response.fromStream(streamedResponse);
      
      print('🔍 Response status: ${response.statusCode}');
      print('🔍 Response body length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return MedicalProcessorResult.fromJson(jsonResponse);
      } else if (response.statusCode == 400) {
        // Handle bad request (invalid file, etc.)
        try {
          final errorResponse = json.decode(response.body);
          final errorMessage = errorResponse['error'] ?? errorResponse.toString();
          return MedicalProcessorResult.failure(error: errorMessage);
        } catch (e) {
          return MedicalProcessorResult.failure(error: response.body);
        }
      } else if (response.statusCode == 401) {
        return MedicalProcessorResult.failure(error: 'Authentication failed');
      } else if (response.statusCode == 500) {
        // Handle server error
        try {
          final errorResponse = json.decode(response.body);
          final errorMessage = errorResponse['error'] ?? 'Internal server error';
          return MedicalProcessorResult.failure(error: errorMessage);
        } catch (e) {
          return MedicalProcessorResult.failure(error: 'Internal server error');
        }
      } else {
        return MedicalProcessorResult.failure(
          error: 'Failed to process PDF. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('🔍 Exception in processPdf: $e');
      if (e.toString().contains('SocketException')) {
        return MedicalProcessorResult.failure(
          error: 'Network error: Cannot connect to server',
        );
      } else if (e.toString().contains('timeout')) {
        return MedicalProcessorResult.failure(
          error: 'Request timeout: PDF processing is taking too long',
        );
      } else if (e.toString().contains('FileSystemException')) {
        return MedicalProcessorResult.failure(
          error: 'File error: Cannot read the PDF file',
        );
      } else {
        return MedicalProcessorResult.failure(
          error: 'Error: ${e.toString()}',
        );
      }
    }
  }
}