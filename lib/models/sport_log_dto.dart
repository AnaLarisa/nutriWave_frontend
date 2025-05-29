class SportLogDto {
  final String description;
  final double caloriesBurned;

  SportLogDto({
    required this.description,
    required this.caloriesBurned,
  });

  factory SportLogDto.fromJson(Map<String, dynamic> json) {
    return SportLogDto(
      description: json['description'] ?? '',
      caloriesBurned: (json['caloriesBurned'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'caloriesBurned': caloriesBurned,
    };
  }

  @override
  String toString() {
    return 'SportLogDto(description: $description, caloriesBurned: $caloriesBurned)';
  }
}