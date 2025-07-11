import 'package:flutter/material.dart';
import '../services/sport_client.dart';
import '../models/sport_log_dto.dart';

class SportStatusPage extends StatefulWidget {
  const SportStatusPage({super.key});

  @override
  State<SportStatusPage> createState() => _SportStatusPageState();
}

class _SportStatusPageState extends State<SportStatusPage> {
  final SportClient _sportClient = SportClient();
  List<SportLogDto> _sportLogs = [];
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
    _loadSportLogs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSportLogs() async {
    if (!mounted) return;
    
    print('🏃 Loading sport logs for date: $_selectedDate');
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _sportClient.getSportLogs(date: _selectedDate);
      
      print('🏃 Sport logs result: ${result.isSuccess ? 'SUCCESS' : 'FAILED'}');
      if (result.isSuccess) {
        print('🏃 Received ${result.sportLogs?.length ?? 0} sport logs');
        result.sportLogs?.forEach((log) {
          print('   - ${log.description}: ${log.caloriesBurned} cal');
        });
      } else {
        print('❌ Error: ${result.error}');
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (result.isSuccess) {
            _sportLogs = result.sportLogs ?? [];
            print('🏃 State updated, _sportLogs length: ${_sportLogs.length}');
          } else {
            _error = result.error;
          }
        });
      }
    } catch (e) {
      print('🏃 Exception in _loadSportLogs: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Unexpected error: $e';
        });
      }
    }
  }

  Future<void> _removeSportLog(SportLogDto sportLog) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Sport Activity'),
        content: Text('Are you sure you want to remove "${sportLog.description}"?'),
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
      
      final result = await _sportClient.removeSportIntake(
        description: sportLog.description,
      );

      if (mounted) {
        scaffoldMessenger.clearSnackBars();
        
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              result.isSuccess 
                  ? result.message ?? 'Sport activity removed successfully'
                  : result.error ?? 'Failed to remove sport activity',
            ),
            backgroundColor: result.isSuccess 
                ? const Color(0xFF4ECDC4) 
                : theme.colorScheme.error,
            duration: const Duration(seconds: 2),
          ),
        );

        if (result.isSuccess) {
          print('🏃 Sport removed successfully, refreshing list...');
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            await _loadSportLogs();
            print('🏃 Sport list refreshed, current count: ${_sportLogs.length}');
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

  void _showAddSportDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Sport Activity'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Activity description',
            hintText: 'e.g., 30 minutes running, 1 hour gym workout',
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
                
                final result = await _sportClient.addSportIntake(
                  description: controller.text.trim(),
                );
                
                if (mounted) {
                  scaffoldMessenger.clearSnackBars();
                  
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        result.isSuccess 
                            ? result.message ?? 'Sport activity added successfully'
                            : result.error ?? 'Failed to add sport activity',
                      ),
                      backgroundColor: result.isSuccess 
                          ? const Color(0xFF4ECDC4) 
                          : theme.colorScheme.error,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  
                  if (result.isSuccess) {
                    print('🏃 Sport added successfully, refreshing list...');
                    await Future.delayed(const Duration(milliseconds: 500));
                    if (mounted) {
                      await _loadSportLogs(); 
                      print('🏃 Sport list refreshed, current count: ${_sportLogs.length}');
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
        title: const Text('Sport Status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSportLogs,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSportLogs,
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
                            'You can only add sport activities for today. This is a view-only mode for past dates.',
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
                      Icons.sports_gymnastics,
                      color: const Color(0xFF4ECDC4),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sport Activities (${_sportLogs.length})',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (_sportLogs.isEmpty)
                  _buildEmptyState()
                else
                  _buildSportLogsList(),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: _isToday ? FloatingActionButton(
        onPressed: _showAddSportDialog,
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
              color: const Color(0xFF4ECDC4),
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
                  _loadSportLogs();
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
              onPressed: _loadSportLogs,
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
                    Icons.sports_gymnastics,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No sport activities logged',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start logging your workouts to see them here',
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
                          color: const Color(0xFF4ECDC4).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add_circle_outline,
                          color: const Color(0xFF4ECDC4),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Sport Activity',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: const Color(0xFF4ECDC4),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Log your workouts to track calories burned',
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
                      onPressed: _isToday ? _showAddSportDialog : null,
                      icon: const Icon(Icons.sports_gymnastics),
                      label: Text(_isToday ? 'Add Sport Activity' : 'Cannot add activities for past dates'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isToday ? const Color(0xFF4ECDC4) : Colors.grey,
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
            color: const Color(0xFF4ECDC4).withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: const Color(0xFF4ECDC4),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Quick Tips',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF4ECDC4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip('Include duration and intensity (e.g., "45 minutes moderate cycling")'),
                  _buildTip('Be specific about the activity type for accurate calorie tracking'),
                  _buildTip('Log activities right after completing them'),
                  _buildTip('Include warm-up and cool-down in your total time'),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSportLogsList() {
    // Calculate total calories burned
    final totalCalories = _sportLogs.fold(0.0, (sum, log) => sum + log.caloriesBurned);

    return Column(
      children: [
        // Total calories card
        Card(
          color: const Color(0xFF4ECDC4).withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_fire_department,
                    color: const Color(0xFF4ECDC4),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Calories Burned',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF4ECDC4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${totalCalories.toStringAsFixed(1)} kcal',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF4ECDC4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Sport logs list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _sportLogs.length,
          itemBuilder: (context, index) {
            final sportLog = _sportLogs[index];
            return _buildSportLogCard(sportLog);
          },
        ),
      ],
    );
  }

  Widget _buildSportLogCard(SportLogDto sportLog) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4ECDC4).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.sports_gymnastics,
                color: const Color(0xFF4ECDC4),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sportLog.description,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sportLog.caloriesBurned.toStringAsFixed(1)} calories burned',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF4ECDC4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (_isToday) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _removeSportLog(sportLog),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                tooltip: 'Remove activity',
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
              color: const Color(0xFF4ECDC4),
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