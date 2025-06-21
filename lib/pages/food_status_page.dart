import 'package:flutter/material.dart';
import 'package:nutriwave_frontend/utils/barcode_validator.dart';
import 'package:nutriwave_frontend/widgets/food/date_selector.dart';
import 'package:nutriwave_frontend/widgets/food/empty_state.dart';
import 'package:nutriwave_frontend/widgets/food/error_card.dart';
import 'package:nutriwave_frontend/widgets/food/food_logs_header.dart';
import 'package:nutriwave_frontend/widgets/food/food_logs_list.dart';
import 'package:nutriwave_frontend/widgets/food/loading_widget.dart';
import 'package:nutriwave_frontend/widgets/food/past_date_warning.dart';
import '../widgets/barcode_scanner_page.dart';
import '../utils/loading_dialog.dart';
import '../services/nutrition_client.dart';
import '../dialogs/add_food_dialog.dart';

class FoodStatusPage extends StatefulWidget {
  const FoodStatusPage({super.key});

  @override
  State<FoodStatusPage> createState() => _FoodStatusPageState();
}

class _FoodStatusPageState extends State<FoodStatusPage> {
  final NutritionClient _nutritionClient = NutritionClient();
  List<String> _foodLogs = [];
  bool _isLoading = true;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  bool get _isToday {
    final today = DateTime.now();
    return _selectedDate.year == today.year &&
           _selectedDate.month == today.month &&
           _selectedDate.day == today.day;
  }

  @override
  void initState() {
    super.initState();
    _loadFoodLogs();
  }

  Future<void> _loadFoodLogs() async {
    if (!mounted) return;
    
    print('🍽️ Loading food logs for date: $_selectedDate');
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _nutritionClient.getFoodLogs(date: _selectedDate);
      
      print('🍽️ Food logs result: ${result.isSuccess ? 'SUCCESS' : 'FAILED'}');
      if (result.isSuccess) {
        print('🍽️ Received ${result.foodLogs?.length ?? 0} food logs');
        result.foodLogs?.forEach((log) {
          print('   - $log');
        });
      } else {
        print('❌ Error: ${result.error}');
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (result.isSuccess) {
            _foodLogs = result.foodLogs ?? [];
            print('🍽️ State updated, _foodLogs length: ${_foodLogs.length}');
          } else {
            _error = result.error;
          }
        });
      }
    } catch (e) {
      print('🍽️ Exception in _loadFoodLogs: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Unexpected error: $e';
        });
      }
    }
  }

  Future<void> _removeFoodLog(String foodDescription) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Food Item'),
        content: Text('Are you sure you want to remove "$foodDescription"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = true;
      });
      
      final result = await _nutritionClient.removeFoodIntake(
        description: foodDescription,
      );

      if (mounted) {
        scaffoldMessenger.clearSnackBars();
        
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              result.isSuccess 
                  ? result.message ?? 'Food item removed successfully'
                  : result.error ?? 'Failed to remove food item',
            ),
            backgroundColor: result.isSuccess 
                ? const Color(0xFF3fc97c) 
                : theme.colorScheme.error,
            duration: const Duration(seconds: 2),
          ),
        );

        if (result.isSuccess) {
          print('🍽️ Food removed successfully, refreshing list...');
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            await _loadFoodLogs();
            print('🍽️ Food list refreshed, current count: ${_foodLogs.length}');
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    }
  }

void _showAddFoodDialog() {
  AddFoodDialog.show(
    context, 
    onSuccess: () async {
      print('🍽️ Food added successfully, refreshing list...');
      setState(() {
        _isLoading = true;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await _loadFoodLogs(); 
        print('🍽️ Food list refreshed, current count: ${_foodLogs.length}');
      }
    },
    onScanBarcode: _handleBarcodeScanning, // ADD THIS LINE
  );
}

Future<void> _handleBarcodeScanning() async {
  try {
    print('📱 _handleBarcodeScanning: Starting barcode scan...');
    
    // Navigate to barcode scanner page
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerPage(),
      ),
    );

    print('📱 _handleBarcodeScanning: Scanner returned with result: $result');

    // Check if scan was cancelled or no result
    if (result == null || result.isEmpty) {
      print('📱 _handleBarcodeScanning: Scan was cancelled or no result');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barcode scan cancelled'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    print('📱 _handleBarcodeScanning: Validating barcode: $result');
    // Validate barcode
    if (!BarcodeValidator.isValid(result)) {
      print('📱 _handleBarcodeScanning: Invalid barcode format: $result');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid barcode: $result'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    print('📱 _handleBarcodeScanning: Barcode is valid, proceeding with API call');
    
    if (!mounted) {
      print('📱 _handleBarcodeScanning: Widget not mounted, aborting');
      return;
    }

    print('📱 _handleBarcodeScanning: Widget is mounted, making API call...');
    
    // Set loading state
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Make API call with loading dialog
      final apiResult = await LoadingDialog.showWithFuture(
        context,
        _nutritionClient.addBarcodeIntake(barcode: result),
        'Processing barcode...',
      );
      
      print('📱 _handleBarcodeScanning: API call completed with result: $apiResult');

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              apiResult.isSuccess 
                  ? '✓ Added: ${apiResult.foodName ?? 'Food item'}' 
                  : apiResult.error ?? 'Failed to add food item',
            ),
            backgroundColor: apiResult.isSuccess 
                ? const Color(0xFF3fc97c) 
                : Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
        
        if (apiResult.isSuccess) {
          print('📱 _handleBarcodeScanning: Success, refreshing food list...');
          // Refresh the food list
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            await _loadFoodLogs();
          }
        } else {
          // Reset loading state on error
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('📱 _handleBarcodeScanning: API call failed with exception: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing barcode: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  } catch (e, stackTrace) {
    print('📱 _handleBarcodeScanning: Error: $e');
    print('📱 _handleBarcodeScanning: Stack trace: $stackTrace');
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFoodLogs,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFoodLogs,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DateSelector(
                selectedDate: _selectedDate,
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                  _loadFoodLogs();
                },
              ),
              const SizedBox(height: 20),

              if (!_isToday) ...[
                PastDateWarning(),
                const SizedBox(height: 16),
              ],

              if (_isLoading)
                const LoadingWidget(),
              
              if (_error != null && !_isLoading)
                ErrorCard(
                  error: _error!,
                  onRetry: _loadFoodLogs,
                ),
              
              if (!_isLoading && _error == null) ...[
                FoodLogsHeader(foodCount: _foodLogs.length),
                const SizedBox(height: 16),
                
                if (_foodLogs.isEmpty)
                  EmptyState(
                    isToday: _isToday,
                    onAddFood: _showAddFoodDialog,
                  )
                else
                  FoodLogsList(
                    foodLogs: _foodLogs,
                    isToday: _isToday,
                    onRemoveFood: _removeFoodLog,
                  ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: _isToday ? FloatingActionButton(
        onPressed: _showAddFoodDialog,
        child: const Icon(Icons.add),
      ) : null,
    );
  }
}
