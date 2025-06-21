import 'package:flutter/material.dart';

class EmptyStateCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }
}
