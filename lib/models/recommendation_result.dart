class RecommendationResult {
  final bool isSuccess;
  final String? recommendations;
  final String? error;

  RecommendationResult._({
    required this.isSuccess,
    this.recommendations,
    this.error,
  });

  factory RecommendationResult.success({required String recommendations}) {
    return RecommendationResult._(isSuccess: true, recommendations: recommendations);
  }

  factory RecommendationResult.failure({required String error}) {
    return RecommendationResult._(isSuccess: false, error: error);
  }
}