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
                          ? const Color(0xFF3fc97c) 
                          : Theme.of(context).colorScheme.error,
                    ),
                  );
                  
                  if (result.isSuccess) {
                    // Navigate back to home page to see updated nutrition
                    Navigator.pushReplacementNamed(context, '/');
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              children: [
                Icon(
                  Icons.restaurant,
                  color: const Color(0xFF3fc97c),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Food Management',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Add Food Card
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
                        onPressed: _showAddFoodDialog,
                        icon: const Icon(Icons.restaurant),
                        label: const Text('Add Food Item'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3fc97c),
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

            // Quick Tips Card
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

            const SizedBox(height: 16),

            // Navigation Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'View Your Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/');
                            },
                            icon: const Icon(Icons.dashboard, size: 18),
                            label: const Text('Today\'s Nutrients'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF3fc97c),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {
                              // Navigate to sport status (will be handled by drawer)
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.sports_gymnastics, size: 18),
                            label: const Text('Sport Status'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF4ECDC4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodDialog,
        child: const Icon(Icons.add),
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