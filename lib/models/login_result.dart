class LoginResult {
  final bool isSuccess;
  final String? token;
  final String? error;
  
  LoginResult._({
    required this.isSuccess,
    this.token,
    this.error,
  });
  
  factory LoginResult.success({required String token}) {
    return LoginResult._(isSuccess: true, token: token);
  }
  
  factory LoginResult.failure({required String error}) {
    return LoginResult._(isSuccess: false, error: error);
  }
}
