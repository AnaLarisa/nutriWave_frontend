import 'package:flutter/material.dart';
import '../models/nutrient_status.dart';
import '../theme/nutriwave_theme.dart';
import '../utils/nutrient_icons.dart';

class NutrientsListWidget extends StatelessWidget {
  final List<NutrientStatus> nutritionData;

  const NutrientsListWidget({
    super.key,
    required this.nutritionData,
  });

  @override
  Widget build(BuildContext context) {
    if (nutritionData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.no_food,
                  size: 48,
                  color: context.mediumGray,
                ),
                const SizedBox(height: 16),
                Text(
                  'No nutrition data available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.mediumGray,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start logging your meals to see nutrition data',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: nutritionData.length,
      itemBuilder: (context, index) {
        final nutrient = nutritionData[index];
        return _buildNutrientCard(context, nutrient);
      },
    );
  }

  Widget _buildNutrientCard(BuildContext context, NutrientStatus nutrient) {
    final progress = nutrient.progressPercentage / 100;
    final isExceeded = nutrient.isExceeded;
    
    final progressColor = isExceeded 
        ? const Color(0xFFFF6B35) // Vibrant orange for exceeded
        : nutrient.isGoalAchieved 
            ? context.primaryGreen 
            : const Color(0xFF4A90E2); // Vibrant blue for in progress

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    NutrientIcons.getIcon(nutrient.nutrientName),
                    color: progressColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nutrient.nutrientName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : const Color(0xFF2C3E50),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${nutrient.progressPercentage.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: 'Current: ',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? const Color(0xFFB0BEC5) 
                                    : const Color(0xFF546E7A),
                              ),
                            ),
                            TextSpan(
                              text: '${nutrient.currentIntake.toStringAsFixed(1)} ${nutrient.measuringUnit}',
                              style: TextStyle(
                                color: progressColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: 'Goal: ',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? const Color(0xFF90A4AE) 
                                    : const Color(0xFF607D8B),
                              ),
                            ),
                            TextSpan(
                              text: '${nutrient.dailyGoal.toStringAsFixed(1)} ${nutrient.measuringUnit}',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? const Color(0xFFCFD8DC) 
                                    : const Color(0xFF455A64),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isExceeded 
                        ? const Color(0xFFFF6B35).withOpacity(0.1)
                        : progressColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isExceeded 
                          ? const Color(0xFFFF6B35).withOpacity(0.3)
                          : progressColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isExceeded 
                        ? '+${(-nutrient.remainingIntake).toStringAsFixed(1)}'
                        : '${nutrient.remainingIntake.toStringAsFixed(1)} left',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isExceeded ? const Color(0xFFFF6B35) : progressColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: progressColor.withOpacity(0.2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: progressColor,
                    boxShadow: [
                      BoxShadow(
                        color: progressColor.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}