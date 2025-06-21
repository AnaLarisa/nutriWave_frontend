class FoodIntakeResult {
  final bool isSuccess;
  final String? message;
  final String? error;

  FoodIntakeResult._({
    required this.isSuccess,
    this.message,
    this.error,
  });

  factory FoodIntakeResult.success({String? message}) {
    return FoodIntakeResult._(isSuccess: true, message: message);
  }

  factory FoodIntakeResult.failure({required String error}) {
    return FoodIntakeResult._(isSuccess: false, error: error);
  }
}
