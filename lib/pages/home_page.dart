import 'package:flutter/material.dart';
import '../services/authentication_client.dart';
import '../services/nutrition_client.dart';
import '../models/nutrient_status.dart';
import '../widgets/date_selector_widget.dart';
import '../widgets/error_card_widget.dart';
import '../widgets/macro_summary_widget.dart';
import '../widgets/nutrients_list_widget.dart';
import '../widgets/dual_fab_widget.dart';
import '../dialogs/add_food_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NutritionClient _nutritionClient = NutritionClient();
  List<NutrientStatus> _nutritionData = [];
  bool _isLoading = true;
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
      } else {
        _error = result.error;
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriWave'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNutritionData,
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
              // Date selector
              DateSelectorWidget(
                selectedDate: _selectedDate,
                onDateChanged: _onDateChanged,
              ),
              const SizedBox(height: 20),

              // Loading/Error states
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
              
              // Nutrition content
              if (!_isLoading && _error == null) ...[
                // Macro summary cards
                if (_macronutrients.isNotEmpty) ...[
                  Text(
                    'Today\'s Overview',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  MacroSummaryWidget(macronutrients: _macronutrients),
                  const SizedBox(height: 24),
                ],

                // All nutrients list
                Text(
                  'Detailed Nutrition',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                NutrientsListWidget(nutritionData: _nutritionData),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: const DualFABWidget(),
    );
  }
}