import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../helpers/constants.dart';
import '../services/authentication_client.dart';

class ReportDownloadResult {
  final bool isSuccess;
  final String? filePath;
  final String? taskId;
  final String? error;

  ReportDownloadResult._({
    required this.isSuccess,
    this.filePath,
    this.taskId,
    this.error,
  });

  factory ReportDownloadResult.success({String? filePath, String? taskId}) {
    return ReportDownloadResult._(isSuccess: true, filePath: filePath, taskId: taskId);
  }

  factory ReportDownloadResult.failure({required String error}) {
    return ReportDownloadResult._(isSuccess: false, error: error);
  }
}

class ReportClient {
  // Singleton pattern
  static final ReportClient _instance = ReportClient._internal();
  factory ReportClient() => _instance;
  ReportClient._internal();

  Future<ReportDownloadResult> downloadReport({
    required String reportType, // 'pdf', 'csv', or 'hl7'
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final authClient = AuthenticationClient();
      
      if (!authClient.isAuthenticated) {
        return ReportDownloadResult.failure(error: 'Please log in to download reports');
      }

      // Request storage permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        return ReportDownloadResult.failure(error: 'Storage permission is required to download files');
      }

      // Format dates as YYYY-MM-DD (matching your backend expectation)
      final startDateString = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endDateString = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      
      print('📄 Downloading $reportType report from $startDateString to $endDateString');
      
      final url = '${Constants.baseUrl}/api/Report/$reportType?startDate=${Uri.encodeComponent(startDateString)}&endDate=${Uri.encodeComponent(endDateString)}';
      
      print('📄 Report URL: $url');
      
      // Get downloads directory
      final savedDir = await _getDownloadsDirectory();
      
      // Generate filename that matches your backend pattern
      final extension = _getFileExtension(reportType);
      final fileName = 'NutrientReport_${startDateString.replaceAll('-', '')}_${endDateString.replaceAll('-', '')}.$extension';
      
      print('📄 Downloading to: $savedDir/$fileName');
      
      // Start download using flutter_downloader
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: savedDir,
        fileName: fileName,
        headers: {
          'Authorization': 'Bearer ${authClient.currentToken}',
        },
        showNotification: true, // Shows download progress in notification
        openFileFromNotification: true, // Allows opening file from notification
        saveInPublicStorage: true, // Saves to public Downloads folder
      );

      if (taskId != null) {
        return ReportDownloadResult.success(
          filePath: '$savedDir/$fileName',
          taskId: taskId,
        );
      } else {
        return ReportDownloadResult.failure(error: 'Failed to start download');
      }
    } catch (e) {
      print('📄 Exception in downloadReport: $e');
      if (e.toString().contains('SocketException')) {
        return ReportDownloadResult.failure(
          error: 'No internet connection. Please check your network',
        );
      } else {
        return ReportDownloadResult.failure(
          error: 'Something went wrong. Please try again',
        );
      }
    }
  }

  Future<bool> _requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        // For Android 13+ (API 33+), we need notification permission
        if (await _getAndroidVersion() >= 33) {
          var status = await Permission.notification.status;
          if (!status.isGranted) {
            status = await Permission.notification.request();
          }
          return status.isGranted;
        } else {
          // For older Android versions, request storage permission
          var status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
          }
          return status.isGranted;
        }
      } else if (Platform.isIOS) {
        // iOS doesn't need explicit permission for downloads
        return true;
      }
      return false;
    } catch (e) {
      print('📄 Error requesting permission: $e');
      return false;
    }
  }

  Future<int> _getAndroidVersion() async {
    try {
      if (Platform.isAndroid) {
        final result = await Process.run('getprop', ['ro.build.version.sdk']);
        return int.tryParse(result.stdout.toString().trim()) ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<String> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // Use the public Downloads directory
      return '/storage/emulated/0/Download';
    } else {
      // For iOS, use documents directory
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  String _getFileExtension(String reportType) {
    switch (reportType.toLowerCase()) {
      case 'pdf':
        return 'pdf';
      case 'csv':
        return 'csv';
      case 'hl7':
        return 'hl7';
      default:
        return 'txt';
    }
  }

  // Optional: Method to check download status
  Future<DownloadTaskStatus?> getDownloadStatus(String taskId) async {
    try {
      final tasks = await FlutterDownloader.loadTasks();
      final task = tasks?.firstWhere((task) => task.taskId == taskId);
      return task?.status;
    } catch (e) {
      print('📄 Error getting download status: $e');
      return null;
    }
  }
}