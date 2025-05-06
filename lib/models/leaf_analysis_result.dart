class LeafAnalysisResult {
  final String diagnosis;
  final String treatment;
  final String prevention;

  LeafAnalysisResult({
    required this.diagnosis,
    required this.treatment,
    required this.prevention,
  });

  factory LeafAnalysisResult.fromJson(Map<String, dynamic> json) {
    return LeafAnalysisResult(
      diagnosis: json['diagnosis'] ?? '',
      treatment: json['treatment'] ?? '',
      prevention: json['prevention'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diagnosis': diagnosis,
      'treatment': treatment,
      'prevention': prevention,
    };
  }
} 