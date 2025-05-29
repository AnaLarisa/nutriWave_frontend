import 'package:flutter/material.dart';
import '../pages/sport_status_page.dart';
import '../pages/food_status_page.dart';

class DualFABWidget extends StatelessWidget {
  const DualFABWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "add_sport",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SportStatusPage()),
            );
          },
          backgroundColor: const Color(0xFF4ECDC4),
          child: const Icon(Icons.sports_gymnastics),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: "add_food", 
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FoodStatusPage()),
            );
          },
          backgroundColor: const Color(0xFF3fc97c),
          child: const Icon(Icons.restaurant),
        ),
      ],
    );
  }
}