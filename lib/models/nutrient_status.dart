class NutrientStatus {
  final String nutrientName;
  final double dailyGoal;
  final double currentIntake;
  final double remainingIntake;
  final String measuringUnit;

  NutrientStatus({
    required this.nutrientName,
    required this.dailyGoal,
    required this.currentIntake,
    required this.remainingIntake,
    required this.measuringUnit,
  });

  // Get percentage of goal achieved
  double get progressPercentage {
    if (dailyGoal == 0) return 0;
    return (currentIntake / dailyGoal * 100).clamp(0, 100);
  }
  
  // Check if goal is achieved
  bool get isGoalAchieved => currentIntake >= dailyGoal;
  
  // Check if intake exceeds goal
  bool get isExceeded => currentIntake > dailyGoal;

  factory NutrientStatus.fromJson(Map<String, dynamic> json) {
    return NutrientStatus(
      nutrientName: json['nutrientName'] ?? '',
      dailyGoal: (json['dailyGoal'] ?? 0).toDouble(),
      currentIntake: (json['currentIntake'] ?? 0).toDouble(),
      remainingIntake: (json['remainingIntake'] ?? 0).toDouble(),
      measuringUnit: json['measuringUnit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nutrientName': nutrientName,
      'dailyGoal': dailyGoal,
      'currentIntake': currentIntake,
      'remainingIntake': remainingIntake,
      'measuringUnit': measuringUnit,
    };
  }

  @override
  String toString() {
    return 'NutrientStatus(nutrientName: $nutrientName, currentIntake: $currentIntake/$dailyGoal $measuringUnit, remaining: $remainingIntake)';
  }
}