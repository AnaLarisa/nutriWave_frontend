import 'package:flutter/material.dart';

class FoodLogCard extends StatelessWidget {
  final String foodDescription;
  final bool isToday;
  final VoidCallback onRemove;

  const FoodLogCard({
    required this.foodDescription,
    required this.isToday,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
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
            if (isToday) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRemove,
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
}