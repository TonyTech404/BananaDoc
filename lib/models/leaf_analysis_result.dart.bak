class LeafAnalysisResult {
  final String diagnosis;
  final String treatment;
  final String prevention;
  final String deficiencyType;
  final double confidence;

  LeafAnalysisResult({
    required this.diagnosis,
    required this.treatment,
    required this.prevention,
    this.deficiencyType = '',
    this.confidence = 0.0,
  });

  factory LeafAnalysisResult.fromJson(Map<String, dynamic> json) {
    return LeafAnalysisResult(
      diagnosis: json['diagnosis'] ?? '',
      treatment: json['treatment'] ?? '',
      prevention: json['prevention'] ?? '',
      deficiencyType: json['deficiency'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diagnosis': diagnosis,
      'treatment': treatment,
      'prevention': prevention,
      'deficiency': deficiencyType,
      'confidence': confidence,
    };
  }
}
