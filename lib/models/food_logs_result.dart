class FoodLogsResult {
  final bool isSuccess;
  final List<String>? foodLogs;
  final String? error;

  FoodLogsResult._({
    required this.isSuccess,
    this.foodLogs,
    this.error,
  });

  factory FoodLogsResult.success({required List<String> foodLogs}) {
    return FoodLogsResult._(isSuccess: true, foodLogs: foodLogs);
  }

  factory FoodLogsResult.failure({required String error}) {
    return FoodLogsResult._(isSuccess: false, error: error);
  }
}
