import 'package:flutter/material.dart';
import '../services/nutrition_client.dart';
import '../theme/nutriwave_theme.dart';

class AddFoodDialog {
  static void show(BuildContext context, {required VoidCallback onSuccess}) {
    final controller = TextEditingController();
    final nutritionClient = NutritionClient();
    
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
                final result = await nutritionClient.addFoodIntake(
                  description: controller.text.trim(),
                );
                
                if (context.mounted) {
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
                    onSuccess();
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