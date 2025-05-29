import 'package:flutter/material.dart';
import '../models/nutrient_status.dart';
import '../utils/nutrient_icons.dart';

class MacroSummaryWidget extends StatelessWidget {
  final List<NutrientStatus> macronutrients;

  const MacroSummaryWidget({
    super.key,
    required this.macronutrients,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemCount: macronutrients.length,
      itemBuilder: (context, index) {
        final nutrient = macronutrients[index];
        return _buildMacroCard(context, nutrient, index);
      },
    );
  }

  Widget _buildMacroCard(BuildContext context, NutrientStatus nutrient, int index) {
    // Vibrant colors for each macro card
    final colors = [
      const Color(0xFFFF6B6B), // Vibrant red for Energy
      const Color(0xFF4ECDC4), // Vibrant teal for Protein  
      const Color(0xFF45B7D1), // Vibrant blue for Carbs
      const Color(0xFFf39c12), // Vibrant orange for Total Fat
    ];
    final color = colors[index % colors.length];

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row with icon and percentage
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      NutrientIcons.getIcon(nutrient.nutrientName),
                      color: color,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      nutrient.nutrientName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '${nutrient.progressPercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Current/Goal values in one line
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: nutrient.currentIntake.toStringAsFixed(1),
                            style: TextStyle(color: color),
                          ),
                          TextSpan(
                            text: ' / ${nutrient.dailyGoal.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: color.withOpacity(0.6),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    nutrient.measuringUnit,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Progress bar
              Container(
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1.5),
                  color: color.withOpacity(0.2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (nutrient.progressPercentage / 100).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1.5),
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}