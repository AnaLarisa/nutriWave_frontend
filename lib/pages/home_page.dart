import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/authentication_client.dart';
import '../services/nutrition_client.dart';
import '../services/medical_processor_client.dart';
import '../services/report_client.dart';
import '../models/nutrient_status.dart';
import '../models/medical_processor_result.dart';
import '../widgets/date_selector_widget.dart';
import '../widgets/error_card_widget.dart';
import '../widgets/macro_summary_widget.dart';
import '../widgets/nutrients_list_widget.dart';
import '../widgets/dual_fab_widget.dart';
import '../dialogs/ai_recommendations_dialog.dart';
import '../theme/nutriwave_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NutritionClient _nutritionClient = NutritionClient();
  final MedicalProcessorClient _medicalClient = MedicalProcessorClient();
  final ReportClient _reportClient = ReportClient();
  List<NutrientStatus> _nutritionData = [];
  bool _isLoading = true;
  bool _isProcessingPdf = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadNutritionData();
  }

  Future<void> _loadNutritionData() async {
    print('🔄 Loading nutrition data for date: $_selectedDate');
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _nutritionClient.getAllNutrition(date: _selectedDate);
    
    print('📊 API Result: ${result.isSuccess ? 'SUCCESS' : 'FAILED'}');
    if (result.isSuccess) {
      print('📊 Received ${result.nutrition?.length ?? 0} nutrients');
      result.nutrition?.forEach((nutrient) {
        print('   - ${nutrient.nutrientName}: ${nutrient.currentIntake}/${nutrient.dailyGoal} ${nutrient.measuringUnit}');
      });
    } else {
      print('❌ Error: ${result.error}');
    }
    
    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _nutritionData = result.nutrition ?? [];
        print('🎯 Macronutrients found: ${_macronutrients.length}');
        print('🎯 Other nutrients found: ${_otherNutrients.length}');
      } else {
        _error = result.error;
      }
    });
  }

  Future<void> _uploadPdfFile() async {
    try {
      // Pick PDF file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        
        setState(() {
          _isProcessingPdf = true;
        });

        // Show processing dialog
        _showProcessingDialog();

        // Process the PDF
        final processingResult = await _medicalClient.processPdf(pdfFile: file);

        // Hide processing dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        setState(() {
          _isProcessingPdf = false;
        });

        if (processingResult.isSuccess && processingResult.data != null) {
          _showResultDialog(processingResult.data!);
          // Refresh nutrition data to reflect any updates
          _loadNutritionData();
        } else {
          _showErrorSnackBar(processingResult.error ?? 'Failed to process PDF');
        }
      }
    } catch (e) {
      setState(() {
        _isProcessingPdf = false;
      });
      if (mounted) {
        Navigator.of(context).pop(); // Close processing dialog if open
      }
      _showErrorSnackBar('Error selecting file: $e');
    }
  }

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                'Processing your medical report...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'This may take a few minutes',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResultDialog(MedicalProcessorData data) {
    final recommendations = data.nutrientRecommendations;
    
    if (recommendations.isEmpty) {
      _showInfoSnackBar('Medical report processed successfully. No specific nutrient recommendations found.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.medical_information,
              color: context.primaryGreen,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Report Processed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Based on your medical report, here are the recommended nutrient adjustments:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: rec.shouldIncrease 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      rec.shouldIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 16,
                      color: rec.shouldIncrease ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rec.nutrient,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    rec.shouldIncrease ? 'Increase' : 'Decrease',
                    style: TextStyle(
                      fontSize: 12,
                      color: rec.shouldIncrease ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: context.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your nutrition tracking has been updated automatically.',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showInfoSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: context.primaryGreen,
        ),
      );
    }
  }

  void _logout(BuildContext context) {
    AuthenticationClient().clearToken();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    _loadNutritionData();
  }

  bool get _isSelectedDateToday {
  final now = DateTime.now();
  return _selectedDate.year == now.year &&
         _selectedDate.month == now.month &&
         _selectedDate.day == now.day;
  }

  void _showReportDownloadDialog() {
    String selectedFormat = 'PDF';
    DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
    DateTime endDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.file_download,
                color: context.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('Download Report'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select report format and date range',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              
              // Format selection
              Text(
                'Report Format',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('PDF', style: TextStyle(fontSize: 14)),
                      value: 'PDF',
                      groupValue: selectedFormat,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedFormat = value!;
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('CSV', style: TextStyle(fontSize: 14)),
                      value: 'CSV',
                      groupValue: selectedFormat,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedFormat = value!;
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('HL7', style: TextStyle(fontSize: 14)),
                      value: 'HL7',
                      groupValue: selectedFormat,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedFormat = value!;
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Date range selection
              Text(
                'Date Range',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              
              // Start date
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Date',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: endDate,
                            );
                            if (picked != null) {
                              setDialogState(() {
                                startDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  '${startDate.day}/${startDate.month}/${startDate.year}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Date',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: startDate,
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                endDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  '${endDate.day}/${endDate.month}/${endDate.year}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Info box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: context.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'The report will be downloaded to your device storage.',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await _downloadReport(
                  selectedFormat.toLowerCase(),
                  startDate,
                  endDate,
                );
              },
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadReport(String format, DateTime startDate, DateTime endDate) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Show loading indicator
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Text('Generating ${format.toUpperCase()} report...'),
          ],
        ),
        backgroundColor: context.primaryGreen,
        duration: const Duration(seconds: 30),
      ),
    );

    final result = await _reportClient.downloadReport(
      reportType: format,
      startDate: startDate,
      endDate: endDate,
    );

    // Clear loading indicator
    scaffoldMessenger.clearSnackBars();

    if (result.isSuccess) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Report download started!'),
              const SizedBox(height: 4),
              Text(
                'Check your Downloads folder or notification bar',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
              ),
            ],
          ),
          backgroundColor: context.primaryGreen,
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to download report'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showAIRecommendations() {
    if (_nutritionData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No nutrition data available for recommendations'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AIRecommendationsDialog(
        nutritionData: _nutritionData,
      ),
    );
  }

  // Get main macronutrients for summary cards
  List<NutrientStatus> get _macronutrients {
    return _nutritionData.where((nutrient) {
      final name = nutrient.nutrientName.toLowerCase();
      return name == 'energy' || 
             name == 'protein' || 
             name == 'carbohydrates' || 
             name == 'total fat';
    }).toList();
  }

  // Get all nutrients except macronutrients for detailed list
  List<NutrientStatus> get _otherNutrients {
    return _nutritionData.where((nutrient) {
      final name = nutrient.nutrientName.toLowerCase();
      return name != 'energy' && 
             name != 'protein' && 
             name != 'carbohydrates' && 
             name != 'total fat';
    }).toList();
  }

  // Check if there are significant nutrient deficiencies
  bool get _hasDeficiencies {
    return _nutritionData.any((nutrient) {
      final percentage = nutrient.dailyGoal > 0 
          ? (nutrient.currentIntake / nutrient.dailyGoal * 100)
          : 100.0;
      return percentage < 70;
    });
  }

  // Get count of deficient nutrients
  int get _deficiencyCount {
    return _nutritionData.where((nutrient) {
      final percentage = nutrient.dailyGoal > 0 
          ? (nutrient.currentIntake / nutrient.dailyGoal * 100)
          : 100.0;
      return percentage < 70;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriWave'),
        automaticallyImplyLeading: false, // Remove back arrow
        leading: IconButton(
          icon: const Icon(Icons.file_download),
          onPressed: _showReportDownloadDialog,
          tooltip: 'Download Report',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNutritionData,
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _isProcessingPdf ? null : _uploadPdfFile,
            tooltip: 'Upload Medical Report',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.account_circle),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNutritionData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Date selector
              DateSelectorWidget(
                selectedDate: _selectedDate,
                onDateChanged: _onDateChanged,
              ),
              const SizedBox(height: 20),

              //Loading/Error states
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
              
              if (_error != null && !_isLoading)
                ErrorCard(
                  error: _error,
                  onRetry: _loadNutritionData,
                ),
              
              //Nutrition content
              if (!_isLoading && _error == null) ...[
                //Macro cards
                if (_macronutrients.isNotEmpty) ...[
                  Text(
                    'Today\'s Overview',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  MacroSummaryWidget(macronutrients: _macronutrients),
                  const SizedBox(height: 24),
                ],

                //AI recommendations button
                if (_nutritionData.isNotEmpty && _isSelectedDateToday) ...[
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _hasDeficiencies 
                            ? [context.darkTeal, context.primaryGreen]
                            : [context.primaryGreen, context.darkTeal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: context.primaryGreen.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showAIRecommendations,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _hasDeficiencies ? Icons.lightbulb : Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _hasDeficiencies 
                                          ? 'Get Smart Recommendations' 
                                          : 'AI Nutrition Insights',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _hasDeficiencies 
                                          ? '$_deficiencyCount nutrients need attention - get personalized suggestions'
                                          : 'Great progress! Get tips to optimize your nutrition',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_hasDeficiencies) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$_deficiencyCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white.withOpacity(0.8),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (_otherNutrients.isNotEmpty) ...[
                  Text(
                    'Detailed Nutrition',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  NutrientsListWidget(nutritionData: _otherNutrients),
                ],
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: const DualFABWidget(),
    );
  }
}