class TestResult {
  final String test;
  final String value;
  final String unit;
  final String range;

  TestResult({
    required this.test,
    required this.value,
    required this.unit,
    required this.range,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      test: json['test'] ?? '',
      value: json['value'] ?? '',
      unit: json['unit'] ?? '',
      range: json['range'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test': test,
      'value': value,
      'unit': unit,
      'range': range,
    };
  }
}

class NutrientRecommendation {
  final String nutrient;
  final String dosageChange;

  NutrientRecommendation({
    required this.nutrient,
    required this.dosageChange,
  });

  factory NutrientRecommendation.fromJson(Map<String, dynamic> json) {
    return NutrientRecommendation(
      nutrient: json['nutrient'] ?? '',
      dosageChange: json['dosage_change'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nutrient': nutrient,
      'dosage_change': dosageChange,
    };
  }

  // Helper to check if recommendation is to increase
  bool get shouldIncrease => dosageChange == '+';
  
  // Helper to check if recommendation is to decrease
  bool get shouldDecrease => dosageChange == '-';
}

class MedicalProcessorData {
  final List<TestResult> testResults;
  final int totalResults;
  final int anonymizedImages;
  final bool success;
  final String errorMessage;
  final List<NutrientRecommendation> nutrientRecommendations;

  MedicalProcessorData({
    required this.testResults,
    required this.totalResults,
    required this.anonymizedImages,
    required this.success,
    required this.errorMessage,
    required this.nutrientRecommendations,
  });

  factory MedicalProcessorData.fromJson(Map<String, dynamic> json) {
    return MedicalProcessorData(
      testResults: (json['testResults'] as List<dynamic>?)
          ?.map((item) => TestResult.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      totalResults: json['totalResults'] ?? 0,
      anonymizedImages: json['anonymizedImages'] ?? 0,
      success: json['success'] ?? false,
      errorMessage: json['errorMessage'] ?? '',
      nutrientRecommendations: (json['nutrientRecommendations'] as List<dynamic>?)
          ?.map((item) => NutrientRecommendation.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testResults': testResults.map((item) => item.toJson()).toList(),
      'totalResults': totalResults,
      'anonymizedImages': anonymizedImages,
      'success': success,
      'errorMessage': errorMessage,
      'nutrientRecommendations': nutrientRecommendations.map((item) => item.toJson()).toList(),
    };
  }

  // Helper methods for easier data access
  List<TestResult> get abnormalResults {
    return testResults.where((result) {
      // This is a simplified check - you might want to implement 
      // more sophisticated logic to determine if a value is abnormal
      return result.range.isNotEmpty && !result.range.contains(result.value);
    }).toList();
  }

  List<NutrientRecommendation> get increaseRecommendations {
    return nutrientRecommendations.where((rec) => rec.shouldIncrease).toList();
  }

  List<NutrientRecommendation> get decreaseRecommendations {
    return nutrientRecommendations.where((rec) => rec.shouldDecrease).toList();
  }
}

class MedicalProcessorResult {
  final bool isSuccess;
  final MedicalProcessorData? data;
  final String? error;

  MedicalProcessorResult._({
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory MedicalProcessorResult.success({required MedicalProcessorData data}) {
    return MedicalProcessorResult._(isSuccess: true, data: data);
  }

  factory MedicalProcessorResult.failure({required String error}) {
    return MedicalProcessorResult._(isSuccess: false, error: error);
  }

  // Factory constructor to create from JSON response
  factory MedicalProcessorResult.fromJson(Map<String, dynamic> json) {
    try {
      final data = MedicalProcessorData.fromJson(json);
      return MedicalProcessorResult.success(data: data);
    } catch (e) {
      return MedicalProcessorResult.failure(error: 'Failed to parse response: $e');
    }
  }
}