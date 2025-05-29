import 'package:flutter/material.dart';
import '../services/authentication_client.dart';
import '../services/nutrition_client.dart';
import '../models/nutrient_status.dart';
import '../theme/nutriwave_theme.dart';

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
              _buildDateSelector(),
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
                _buildErrorCard(),
              
              // Nutrition content
              if (!_isLoading && _error == null) ...[
                // Macro summary cards
                if (_macronutrients.isNotEmpty) ...[
                  Text(
                    'Today\'s Overview',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildMacroSummary(),
                  const SizedBox(height: 24),
                ],

                // All nutrients list
                Text(
                  'Detailed Nutrition',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _buildNutrientsList(),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add food page
          _showAddFoodDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: context.primaryGreen,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Date',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                  });
                  _loadNutritionData();
                }
              },
              icon: const Icon(Icons.edit_calendar),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error Loading Data',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  Text(
                    _error ?? 'Unknown error',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _loadNutritionData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroSummary() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8, // Increased from 1.6 to 1.8 for even less height
      ),
      itemCount: _macronutrients.length,
      itemBuilder: (context, index) {
        final nutrient = _macronutrients[index];
        return _buildMacroCard(nutrient, index);
      },
    );
  }

  Widget _buildMacroCard(NutrientStatus nutrient, int index) {
    // Vibrant colors for each macro card
    final colors = [
      const Color(0xFFFF6B6B), // Vibrant red for Energy
      const Color(0xFF4ECDC4), // Vibrant teal for Protein  
      const Color(0xFF45B7D1), // Vibrant blue for Carbs
      const Color(0xFFf39c12), // Vibrant orange for Total Fat
    ];
    final color = colors[index % colors.length];

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10), // Reduced from 12 to 10
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row with icon and percentage
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5), // Reduced from 6 to 5
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getNutrientIcon(nutrient.nutrientName),
                      color: color,
                      size: 16, // Reduced from 18 to 16
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      nutrient.nutrientName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 10, // Reduced from 11 to 10
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), // Reduced padding
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '${nutrient.progressPercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 8, // Reduced from 9 to 8
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4), // Reduced from 6 to 4
              
              // Current/Goal values in one line
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 12, // Reduced from 14 to 12
                        ),
                        children: [
                          TextSpan(
                            text: nutrient.currentIntake.toStringAsFixed(1),
                            style: TextStyle(color: color),
                          ),
                          TextSpan(
                            text: ' / ${nutrient.dailyGoal.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: color.withOpacity(0.6),
                              fontSize: 9, // Reduced from 10 to 9
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    nutrient.measuringUnit,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      fontSize: 8, // Reduced from 9 to 8
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4), // Reduced from 6 to 4
              
              // Progress bar
              Container(
                height: 3, // Reduced from 4 to 3
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1.5),
                  color: color.withOpacity(0.2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (nutrient.progressPercentage / 100).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1.5),
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientsList() {
    if (_nutritionData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.no_food,
                  size: 48,
                  color: context.mediumGray,
                ),
                const SizedBox(height: 16),
                Text(
                  'No nutrition data available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.mediumGray,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start logging your meals to see nutrition data',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _nutritionData.length,
      itemBuilder: (context, index) {
        final nutrient = _nutritionData[index];
        return _buildNutrientCard(nutrient);
      },
    );
  }

  Widget _buildNutrientCard(NutrientStatus nutrient) {
    final progress = nutrient.progressPercentage / 100;
    final isExceeded = nutrient.isExceeded;
    
    // Use more vibrant colors instead of grey
    final progressColor = isExceeded 
        ? const Color(0xFFFF6B35) // Vibrant orange for exceeded
        : nutrient.isGoalAchieved 
            ? context.primaryGreen 
            : const Color(0xFF4A90E2); // Vibrant blue for in progress

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getNutrientIcon(nutrient.nutrientName),
                    color: progressColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nutrient.nutrientName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : const Color(0xFF2C3E50),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${nutrient.progressPercentage.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: 'Current: ',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? const Color(0xFFB0BEC5) 
                                    : const Color(0xFF546E7A),
                              ),
                            ),
                            TextSpan(
                              text: '${nutrient.currentIntake.toStringAsFixed(1)} ${nutrient.measuringUnit}',
                              style: TextStyle(
                                color: progressColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: 'Goal: ',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? const Color(0xFF90A4AE) 
                                    : const Color(0xFF607D8B),
                              ),
                            ),
                            TextSpan(
                              text: '${nutrient.dailyGoal.toStringAsFixed(1)} ${nutrient.measuringUnit}',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? const Color(0xFFCFD8DC) 
                                    : const Color(0xFF455A64),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isExceeded 
                        ? const Color(0xFFFF6B35).withOpacity(0.1)
                        : progressColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isExceeded 
                          ? const Color(0xFFFF6B35).withOpacity(0.3)
                          : progressColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isExceeded 
                        ? '+${(-nutrient.remainingIntake).toStringAsFixed(1)}'
                        : '${nutrient.remainingIntake.toStringAsFixed(1)} left',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isExceeded ? const Color(0xFFFF6B35) : progressColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: progressColor.withOpacity(0.2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: progressColor,
                    boxShadow: [
                      BoxShadow(
                        color: progressColor.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNutrientIcon(String nutrientName) {
    final name = nutrientName.toLowerCase();
    if (name.contains('calorie') || name.contains('energy')) return Icons.local_fire_department;
    if (name.contains('protein')) return Icons.fitness_center;
    if (name.contains('carb')) return Icons.grain;
    if (name.contains('fat')) return Icons.water_drop;
    if (name.contains('vitamin')) return Icons.medication;
    if (name.contains('mineral')) return Icons.diamond;
    if (name.contains('fiber')) return Icons.eco;
    if (name.contains('sugar')) return Icons.cake;
    if (name.contains('sodium')) return Icons.scatter_plot;
    if (name.contains('calcium')) return Icons.health_and_safety;
    if (name.contains('iron')) return Icons.build;
    if (name.contains('zinc')) return Icons.shield;
    if (name.contains('potassium')) return Icons.electric_bolt;
    if (name.contains('magnesium')) return Icons.spa;
    return Icons.restaurant;
  }

  void _showAddFoodDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Food'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Food description',
            hintText: 'e.g., 2 slices of bread',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                final result = await _nutritionClient.addFoodIntake(
                  description: controller.text.trim(),
                );
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result.isSuccess 
                            ? result.message ?? 'Food added successfully'
                            : result.error ?? 'Failed to add food',
                      ),
                      backgroundColor: result.isSuccess 
                          ? context.primaryGreen 
                          : Theme.of(context).colorScheme.error,
                    ),
                  );
                  
                  if (result.isSuccess) {
                    _loadNutritionData();
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}