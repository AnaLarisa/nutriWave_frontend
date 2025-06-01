import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nutrient_status.dart';
import '../models/recommendation_result.dart';

class AIRecommendationsClient {
  static final AIRecommendationsClient _instance = AIRecommendationsClient._internal();
  factory AIRecommendationsClient() => _instance;
  AIRecommendationsClient._internal();

  static const String _geminiApiKey = 'AIzaSyAFqIel0KZx-00HMT3ybXcnbq1IinPZFlo';

  
  Future<RecommendationResult> getRecommendations({
    required List<NutrientStatus> nutritionData,
    String? userPreferences, // Keep for compatibility but make optional
  }) async {
    try {
      // Try Gemini first, fallback to local recommendations
      final geminiResult = await _getGeminiRecommendations(nutritionData);
      if (geminiResult != null) {
        return geminiResult;
      }
      
      // Fallback to local recommendations
      return _getLocalRecommendations(nutritionData);
    } catch (e) {
      // If everything fails, return local recommendations
      return _getLocalRecommendations(nutritionData);
    }
  }

  Future<RecommendationResult?> _getGeminiRecommendations(
    List<NutrientStatus> nutritionData
  ) async {
    try {
      final nutritionSummary = _prepareNutritionSummary(nutritionData);
      final prompt = _buildSimplifiedPrompt(nutritionSummary);
      
      // Use gemini-2.0-flash as requested
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_geminiApiKey');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [{
            'parts': [{'text': prompt}]
          }]
        }),
      ).timeout(const Duration(seconds: 30));

      print('🤖 Gemini API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['candidates'] != null && 
            responseData['candidates'].isNotEmpty &&
            responseData['candidates'][0]['content'] != null) {
          
          final recommendations = responseData['candidates'][0]['content']['parts'][0]['text'];
          print('🤖 Gemini recommendations received successfully');
          return RecommendationResult.success(recommendations: recommendations);
        }
      } else {
        print('🤖 Gemini API Error: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      print('🤖 Gemini API Exception: $e');
      return null;
    }
  }

  String _buildSimplifiedPrompt(Map<String, dynamic> nutritionSummary) {
    final deficiencies = nutritionSummary['deficiencies'] as List;
    
    return '''
Analyze my nutrition data and provide specific, actionable recommendations to meet my daily goals.

NUTRITION STATUS:
${_formatNutritionData(nutritionSummary)}

Please provide:
1. Top 3 food recommendations with portions to address my biggest nutrient gaps
2. One simple recipe or meal idea that would help significantly
3. Brief timing suggestion (when to eat these)

Keep it concise, practical, and focused on easily available foods. Use emojis and bullet points for better readability.
''';
  }

  RecommendationResult _getLocalRecommendations(List<NutrientStatus> nutritionData) {
    final nutritionSummary = _prepareNutritionSummary(nutritionData);
    final deficiencies = nutritionSummary['deficiencies'] as List<dynamic>;
    
    if (deficiencies.isEmpty) {
      return RecommendationResult.success(
        recommendations: "🎉 **EXCELLENT PROGRESS!**\n\nYou're hitting most of your nutrition targets today! 💪\n\n**To maintain this momentum:**\n• Stay hydrated with 6-8 glasses of water\n• Consider a light, balanced snack if hungry\n• Keep up the great nutrition tracking!\n\n🌟 Your dedication to health is paying off!"
      );
    }

    final recommendations = StringBuffer();
    recommendations.writeln("🍎 **SMART NUTRITION PLAN FOR TODAY**\n");
    
    // Focus on top 3 deficiencies
    final topDeficiencies = deficiencies.take(3).cast<Map<String, dynamic>>().toList();
    
    recommendations.writeln("📊 **Missing Nutrients:**");
    for (int i = 0; i < topDeficiencies.length; i++) {
      final def = topDeficiencies[i];
      final nutrientName = def['name'] as String;
      final needed = def['needed'] as double;
      final unit = def['unit'] as String;
      final percentage = def['percentage'] as int;
      
      recommendations.writeln("${i + 1}. **${nutrientName}** - Need ${needed.toStringAsFixed(1)} $unit more");
    }
    
    recommendations.writeln("\n🥗 **FOOD RECOMMENDATIONS:**\n");
    
    for (int i = 0; i < topDeficiencies.length && i < 3; i++) {
      final def = topDeficiencies[i];
      final nutrientName = def['name'] as String;
      final needed = def['needed'] as double;
      final unit = def['unit'] as String;
      
      recommendations.writeln("**For ${nutrientName}:**");
      recommendations.writeln(_getDetailedFoodSuggestions(nutrientName, needed, unit));
      recommendations.writeln("");
    }

    // Add a simple recipe suggestion
    recommendations.writeln("🍳 **QUICK RECIPE SUGGESTION:**\n");
    recommendations.writeln(_getRecipeSuggestion(topDeficiencies));

    // Add timing suggestion
    final now = DateTime.now();
    final timeOfDay = now.hour < 12 ? "morning" : now.hour < 17 ? "afternoon" : "evening";
    recommendations.writeln("\n⏰ **Best timing:** Since it's $timeOfDay, try incorporating these foods into your next meal or snack for maximum benefit!");

    return RecommendationResult.success(recommendations: recommendations.toString());
  }

  String _getDetailedFoodSuggestions(String nutrientName, double needed, String unit) {
    final name = nutrientName.toLowerCase();
    
    if (name.contains('protein')) {
      return "• **Greek yogurt** (1 cup = 20g protein)\n• **Chicken breast** (100g = 25g protein)\n• **Lentils** (1 cup cooked = 18g protein)\n• **Eggs** (2 large = 12g protein)";
    } else if (name.contains('energy') || name.contains('calorie')) {
      return "• **Banana with peanut butter** (300 calories)\n• **Avocado toast** (350 calories)\n• **Oatmeal with berries** (280 calories)\n• **Trail mix** (250 calories per handful)";
    } else if (name.contains('carbohydrate')) {
      return "• **Sweet potato** (medium = 25g carbs)\n• **Brown rice** (1 cup = 45g carbs)\n• **Oatmeal** (1 cup = 30g carbs)\n• **Whole wheat bread** (2 slices = 24g carbs)";
    } else if (name.contains('fat') || name.contains('total fat')) {
      return "• **Avocado** (half = 15g healthy fats)\n• **Almonds** (handful = 14g fats)\n• **Olive oil** (1 tbsp = 14g fats)\n• **Salmon** (100g = 13g fats)";
    } else if (name.contains('fiber')) {
      return "• **Apple with skin** (medium = 4g fiber)\n• **Black beans** (1 cup = 15g fiber)\n• **Broccoli** (1 cup = 5g fiber)\n• **Chia seeds** (2 tbsp = 10g fiber)";
    } else if (name.contains('calcium')) {
      return "• **Milk** (1 cup = 300mg calcium)\n• **Cheese** (1 oz = 200mg calcium)\n• **Yogurt** (1 cup = 300mg calcium)\n• **Leafy greens** (1 cup = 100mg calcium)";
    } else if (name.contains('iron')) {
      return "• **Spinach** (1 cup cooked = 6mg iron)\n• **Lean beef** (100g = 3mg iron)\n• **Lentils** (1 cup = 6mg iron)\n• **Dark chocolate** (1 oz = 3mg iron)";
    } else if (name.contains('vitamin c')) {
      return "• **Orange** (medium = 70mg vitamin C)\n• **Strawberries** (1 cup = 85mg vitamin C)\n• **Bell pepper** (1 cup = 120mg vitamin C)\n• **Kiwi** (1 medium = 70mg vitamin C)";
    } else if (name.contains('vitamin d')) {
      return "• **Fortified milk** (1 cup = 3µg vitamin D)\n• **Egg yolks** (2 yolks = 1µg vitamin D)\n• **Fortified cereals** (1 serving = 1-3µg)\n• **Canned salmon** (100g = 10µg vitamin D)";
    } else if (name.contains('added sugar')) {
      return "• **Fresh fruits** instead of candy\n• **Dark chocolate** (small piece)\n• **Honey or maple syrup** (1 tsp in tea)\n• **Dried fruits** (dates, raisins - small portions)";
    } else if (name.contains('iodine')) {
      return "• **Iodized salt** (small amounts in cooking)\n• **Seaweed snacks** (1 sheet = 15µg iodine)\n• **Cod** (100g = 110µg iodine)\n• **Shrimp** (100g = 35µg iodine)";
    } else {
      return "• **Fortified foods** (check labels for $nutrientName)\n• **Multivitamin** (consult healthcare provider)\n• **Varied whole foods** (fruits, vegetables, proteins)\n• **Nutrition apps** for tracking specific nutrients";
    }
  }

  String _getRecipeSuggestion(List<Map<String, dynamic>> deficiencies) {
    if (deficiencies.isEmpty) return "**Balanced smoothie** with fruits, yogurt, and spinach!";
    
    final firstDeficiency = deficiencies[0]['name'] as String;
    final name = firstDeficiency.toLowerCase();
    
    if (name.contains('protein')) {
      return "**Power Breakfast Bowl:**\n• 1 cup Greek yogurt\n• 1 tbsp almond butter\n• 1/2 cup berries\n• 1 tbsp chia seeds\n• Drizzle of honey\n\n*Provides 25g+ protein plus healthy fats and fiber!*";
    } else if (name.contains('energy') || name.contains('calorie')) {
      return "**Energy Smoothie:**\n• 1 banana\n• 1 cup oat milk\n• 2 tbsp peanut butter\n• 1 tsp honey\n• 1/2 cup oats\n• Ice cubes\n\n*Blend and enjoy - 400+ calories of sustained energy!*";
    } else if (name.contains('iron')) {
      return "**Iron-Rich Salad:**\n• 2 cups spinach\n• 1/2 cup cooked lentils\n• 1 hard-boiled egg\n• 1/4 avocado\n• Lemon-olive oil dressing\n\n*Vitamin C from lemon helps iron absorption!*";
    } else if (name.contains('calcium')) {
      return "**Calcium Boost Parfait:**\n• 1 cup yogurt\n• 1/4 cup crushed almonds\n• 2 tbsp chia seeds\n• Fresh berries\n• Drizzle of tahini\n\n*Over 400mg calcium in one delicious serving!*";
    } else if (name.contains('vitamin d')) {
      return "**Sunshine Scramble:**\n• 2 eggs (use whole eggs!)\n• 1 cup fortified milk\n• Sautéed mushrooms\n• Slice of fortified bread\n• Side of canned salmon\n\n*Plus 15 minutes of morning sunlight!*";
    } else {
      return "**Nutrient Power Bowl:**\n• 1 cup quinoa\n• Mixed colorful vegetables\n• Lean protein of choice\n• Avocado slices\n• Tahini dressing\n\n*A rainbow of nutrients in one bowl!*";
    }
  }

  String _getQuickSuggestionsForNutrient(String nutrientName) {
    final name = nutrientName.toLowerCase();
    
    if (name.contains('protein')) {
      return "**Protein boost:** Greek yogurt (20g), handful of almonds (6g), or 2 boiled eggs (12g)";
    } else if (name.contains('energy') || name.contains('calorie')) {
      return "**Energy foods:** Banana with peanut butter, avocado toast, or oatmeal with berries";
    } else if (name.contains('carbohydrate')) {
      return "**Healthy carbs:** Sweet potato, quinoa bowl, or whole grain toast";
    } else if (name.contains('fat')) {
      return "**Healthy fats:** Half avocado, mixed nuts, or olive oil drizzle";
    } else if (name.contains('fiber')) {
      return "**Fiber sources:** Apple with skin, black beans, or broccoli";
    } else if (name.contains('calcium')) {
      return "**Calcium rich:** Yogurt, cheese slice, or fortified plant milk";
    } else if (name.contains('iron')) {
      return "**Iron sources:** Spinach salad, lentils, or lean beef";
    } else if (name.contains('vitamin c')) {
      return "**Vitamin C:** Orange, strawberries, or bell pepper strips";
    } else {
      return "**For $nutrientName:** Check fortified foods or nutrition labels";
    }
  }

  String _formatNutritionData(Map<String, dynamic> nutritionSummary) {
    final buffer = StringBuffer();
    final deficiencies = nutritionSummary['deficiencies'] as List;
    
    if (deficiencies.isNotEmpty) {
      buffer.writeln('NEEDS ATTENTION:');
      for (final def in deficiencies.take(5)) { // Limit for mobile
        buffer.writeln('- ${def['name']}: ${def['percentage']}% of goal (need ${def['needed'].toStringAsFixed(1)} ${def['unit']})');
      }
    }
    
    return buffer.toString();
  }

  Map<String, dynamic> _prepareNutritionSummary(List<NutrientStatus> nutritionData) {
    final summary = <String, dynamic>{};
    final deficiencies = <Map<String, dynamic>>[];
    
    for (final nutrient in nutritionData) {
      final percentage = nutrient.dailyGoal > 0 
          ? (nutrient.currentIntake / nutrient.dailyGoal * 100)
          : 0.0;
      
      summary[nutrient.nutrientName] = {
        'current': nutrient.currentIntake,
        'goal': nutrient.dailyGoal,
        'unit': nutrient.measuringUnit,
        'percentage': percentage.round(),
        'remaining': (nutrient.dailyGoal - nutrient.currentIntake).clamp(0, double.infinity),
      };
      
      // Track significant deficiencies (less than 80% of goal for stricter filtering)
      if (percentage < 80 && nutrient.dailyGoal > 0) {
        deficiencies.add({
          'name': nutrient.nutrientName,
          'needed': nutrient.dailyGoal - nutrient.currentIntake,
          'unit': nutrient.measuringUnit,
          'percentage': percentage.round(),
        });
      }
    }
    
    // Sort deficiencies by severity (lowest percentage first)
    deficiencies.sort((a, b) => (a['percentage'] as int).compareTo(b['percentage'] as int));
    
    return {
      'date': DateTime.now().toIso8601String().split('T')[0],
      'nutrients': summary,
      'deficiencies': deficiencies,
      'totalNutrients': nutritionData.length,
    };
  }
}