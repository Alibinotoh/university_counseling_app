class AssessmentResult {
  final String level;
  final double finalScore;
  final bool triggerWarning;

  AssessmentResult({
    required this.level,
    required this.finalScore,
    required this.triggerWarning,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      level: json['stress_level'] ?? "Unknown",
      finalScore: (json['score'] ?? 0.0).toDouble(), 
      triggerWarning: json['trigger_warning'] ?? false,
    );
  }
}