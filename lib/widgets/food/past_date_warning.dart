import 'package:flutter/material.dart';

class PastDateWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }
}
