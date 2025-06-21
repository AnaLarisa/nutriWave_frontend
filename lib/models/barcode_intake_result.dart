class BarcodeIntakeResult {
  final bool isSuccess;
  final String? message;
  final String? foodName;
  final String? error;

  BarcodeIntakeResult._({
    required this.isSuccess,
    this.message,
    this.foodName,
    this.error,
  });

  factory BarcodeIntakeResult.success({String? message, String? foodName}) {
    return BarcodeIntakeResult._(isSuccess: true, message: message, foodName: foodName);
  }

  factory BarcodeIntakeResult.failure({required String error}) {
    return BarcodeIntakeResult._(isSuccess: false, error: error);
  }

  @override
  String toString() {
    return 'BarcodeIntakeResult(isSuccess: $isSuccess, message: $message, foodName: $foodName, error: $error)';
  }
}