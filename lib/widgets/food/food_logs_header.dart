import 'package:flutter/material.dart';

class FoodLogsHeader extends StatelessWidget {
  final int foodCount;

  const FoodLogsHeader({required this.foodCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.restaurant,
          color: const Color(0xFF3fc97c),
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          'Food Items ($foodCount)',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
}
