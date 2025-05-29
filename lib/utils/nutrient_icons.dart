import 'package:flutter/material.dart';

class NutrientIcons {
  static IconData getIcon(String nutrientName) {
    final name = nutrientName.toLowerCase();
    
    // Main macronutrients
    if (name == 'energy') return Icons.local_fire_department;
    if (name == 'protein') return Icons.fitness_center;
    if (name == 'carbohydrates') return Icons.grain;
    if (name == 'total fat') return Icons.water_drop;
    
    // Other fats
    if (name.contains('fat')) return Icons.opacity;
    if (name == 'cholesterol') return Icons.favorite;
    
    // Sugars and fiber
    if (name == 'fiber') return Icons.eco;
    if (name.contains('sugar')) return Icons.cake;
    
    // Water
    if (name == 'water') return Icons.local_drink;
    
    // Vitamins
    if (name.startsWith('vitamin')) return Icons.medication;
    if (name.contains('thiamin') || name.contains('riboflavin') || name.contains('niacin') || 
        name.contains('folate') || name.contains('b')) return Icons.medication;
    
    // Minerals
    if (name == 'calcium') return Icons.health_and_safety;
    if (name == 'iron') return Icons.build;
    if (name == 'magnesium') return Icons.spa;
    if (name == 'phosphorus') return Icons.flash_on;
    if (name == 'potassium') return Icons.electric_bolt;
    if (name == 'sodium') return Icons.scatter_plot;
    if (name == 'zinc') return Icons.shield;
    if (name == 'copper') return Icons.hardware;
    if (name == 'manganese') return Icons.category;
    if (name == 'selenium') return Icons.security;
    if (name == 'iodine') return Icons.science;
    
    // Default
    return Icons.restaurant;
  }
}