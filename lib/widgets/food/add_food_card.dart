import 'package:flutter/material.dart';

class AddFoodCard extends StatelessWidget {
  final VoidCallback onAddFood;

  const AddFoodCard({required this.onAddFood});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                onPressed: onAddFood,
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
    );
  }
}
