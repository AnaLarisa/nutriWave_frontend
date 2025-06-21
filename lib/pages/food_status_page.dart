import 'package:flutter/material.dart';
import '../services/nutrition_client.dart';
import '../theme/nutriwave_theme.dart';

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

  @override
  void dispose() {
    super.dispose();
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
        // Clear any existing snackbars first
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
            duration: const Duration(seconds: 2), // Shorter duration
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
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Food'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Food description',
            hintText: 'e.g., 2 slices of bread, 1 apple, 200g chicken',
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
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final theme = Theme.of(context);
                
                navigator.pop();
                
                if (!mounted) return;
                
                setState(() {
                  _isLoading = true;
                });
                
                final result = await _nutritionClient.addFoodIntake(
                  description: controller.text.trim(),
                );
                
                if (mounted) {
                  // Clear any existing snackbars first
                  scaffoldMessenger.clearSnackBars();
                  
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        result.isSuccess 
                            ? result.message ?? 'Food added successfully'
                            : result.error ?? 'Failed to add food',
                      ),
                      backgroundColor: result.isSuccess 
                          ? const Color(0xFF3fc97c) 
                          : theme.colorScheme.error,
                      duration: const Duration(seconds: 2), // Shorter duration
                    ),
                  );
                  
                  if (result.isSuccess) {
                    print('🍽️ Food added successfully, refreshing list...');
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
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
              _buildDateSelector(),
              const SizedBox(height: 20),

              if (!_isToday) ...[
                Card(
                  color: Colors.orange.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You can only add food items for today. This is a view-only mode for past dates.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
              
              if (_error != null && !_isLoading)
                _buildErrorCard(),
              
              if (!_isLoading && _error == null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.restaurant,
                      color: const Color(0xFF3fc97c),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Food Items (${_foodLogs.length})',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (_foodLogs.isEmpty)
                  _buildEmptyState()
                else
                  _buildFoodLogsList(),
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

  Widget _buildDateSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: const Color(0xFF3fc97c),
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
                  _loadFoodLogs();
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
              onPressed: _loadFoodLogs,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.restaurant,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No food items logged',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start logging your meals to see them here',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        if (_isToday) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3fc97c).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add_circle_outline,
                          color: const Color(0xFF3fc97c),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Food',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: const Color(0xFF3fc97c),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Log your meals to track nutrition',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.white70 
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isToday ? _showAddFoodDialog : null,
                      icon: const Icon(Icons.restaurant),
                      label: Text(_isToday ? 'Add Food Item' : 'Cannot add items for past dates'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isToday ? const Color(0xFF3fc97c) : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            color: const Color(0xFF3fc97c).withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: const Color(0xFF3fc97c),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Quick Tips',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF3fc97c),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip('Be specific with portions (e.g., "200g grilled chicken")'),
                  _buildTip('Include cooking methods (e.g., "fried", "grilled", "boiled")'),
                  _buildTip('Add brand names for packaged foods when possible'),
                  _buildTip('Log meals as soon as possible for better accuracy'),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFoodLogsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _foodLogs.length,
      itemBuilder: (context, index) {
        final foodLog = _foodLogs[index];
        return _buildFoodLogCard(foodLog);
      },
    );
  }

  Widget _buildFoodLogCard(String foodDescription) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3fc97c).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.restaurant,
                color: const Color(0xFF3fc97c),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                foodDescription,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_isToday) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _removeFoodLog(foodDescription),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                tooltip: 'Remove food item',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF3fc97c),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white70 
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}