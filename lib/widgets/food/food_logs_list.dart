import 'package:flutter/material.dart';
import 'package:nutriwave_frontend/widgets/food/food_log_card.dart';

class FoodLogsList extends StatelessWidget {
  final List<String> foodLogs;
  final bool isToday;
  final Function(String) onRemoveFood;

  const FoodLogsList({
    required this.foodLogs,
    required this.isToday,
    required this.onRemoveFood,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: foodLogs.length,
      itemBuilder: (context, index) {
        final foodLog = foodLogs[index];
        return FoodLogCard(
          foodDescription: foodLog,
          isToday: isToday,
          onRemove: () => onRemoveFood(foodLog),
        );
      },
    );
  }
}
