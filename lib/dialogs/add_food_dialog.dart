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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Food description',
                hintText: 'e.g., 2 slices of bread',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // Scan barcode button below the text field
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement barcode scanning functionality
                  print('🔍 Barcode scan button pressed');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Barcode scanning coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Barcode'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: context.primaryGreen),
                  foregroundColor: context.primaryGreen,
                ),
              ),
            ),
          ],
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