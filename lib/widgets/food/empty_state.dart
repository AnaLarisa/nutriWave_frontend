import 'package:flutter/material.dart';
import 'package:nutriwave_frontend/widgets/food/add_food_card.dart';
import 'package:nutriwave_frontend/widgets/food/empty_state_card.dart';
import 'package:nutriwave_frontend/widgets/food/tips_card.dart';

class EmptyState extends StatelessWidget {
  final bool isToday;
  final VoidCallback onAddFood;

  const EmptyState({
    required this.isToday,
    required this.onAddFood,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EmptyStateCard(),
        
        if (isToday) ...[
          const SizedBox(height: 16),
          AddFoodCard(onAddFood: onAddFood),
          const SizedBox(height: 16),
          TipsCard(),
        ],
      ],
    );
  }
}
