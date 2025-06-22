import 'package:flutter/material.dart';
import '../services/nutrition_client.dart';
import '../theme/nutriwave_theme.dart';

class AddFoodDialog {
  static void show(
    BuildContext context, {
    required VoidCallback onSuccess,
    required VoidCallback onScanBarcode,
  }) {
    final controller = TextEditingController();
    final nutritionClient = NutritionClient();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                      // Close dialog and notify parent to handle barcode scanning
                      Navigator.pop(context);
                      onScanBarcode();
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
                    final description = controller.text.trim();

                    // Close dialog first
                    Navigator.pop(context);

                    try {
                      final result = await nutritionClient.addFoodIntake(
                        description: description,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result.isSuccess
                                  ? result.message ?? 'Food added successfully'
                                  : result.error ?? 'Failed to add food',
                            ),
                            backgroundColor:
                                result.isSuccess
                                    ? context.primaryGreen
                                    : Theme.of(context).colorScheme.error,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                      onSuccess();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                        );
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
