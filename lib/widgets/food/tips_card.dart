import 'package:flutter/material.dart';
import 'package:nutriwave_frontend/widgets/food/tip.dart';

class TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
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
            Tip(text: 'Be specific with portions (e.g., "200g grilled chicken")'),
            Tip(text: 'Include cooking methods (e.g., "fried", "grilled", "boiled")'),
            Tip(text: 'Add brand names for packaged foods when possible'),
            Tip(text: 'Log meals as soon as possible for better accuracy'),
            Tip(text: 'Use barcode scanning for packaged foods for better accuracy'),
          ],
        ),
      ),
    );
  }
}
