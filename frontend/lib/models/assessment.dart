class AssessmentResponse {
  final String stressLevel;
  final bool triggerWarning;

  AssessmentResponse({required this.stressLevel, required this.triggerWarning});

  // This converts the JSON from FastAPI into a Flutter Object
  factory AssessmentResponse.fromJson(Map<String, dynamic> json) {
    return AssessmentResponse(
      stressLevel: json['stress_level'],
      triggerWarning: json['trigger_warning'],
    );
  }
}