class AuthResult {
  final bool isSuccess;
  final String? message;
  final String? error;
  
  AuthResult._({
    required this.isSuccess,
    this.message,
    this.error,
  });
  
  factory AuthResult.success({String? message}) {
    return AuthResult._(isSuccess: true, message: message);
  }
  
  factory AuthResult.failure({required String error}) {
    return AuthResult._(isSuccess: false, error: error);
  }
}
