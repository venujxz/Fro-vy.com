/// Represents a user's health-related profile (allergies, conditions, sensitivities).
class HealthProfile {
  List<String> allergies;
  String medicalConditions;
  String otherSensitivities;

  HealthProfile({
    List<String>? allergies,
    this.medicalConditions = 'None',
    this.otherSensitivities = 'Lactose Intolerance',
  }) : allergies = allergies ?? ['Peanuts', 'Shellfish'];

  Map<String, dynamic> toJson() => {
    'allergies': allergies,
    'medicalConditions': medicalConditions,
    'otherSensitivities': otherSensitivities,
  };

  factory HealthProfile.fromJson(Map<String, dynamic> json) => HealthProfile(
    allergies: (json['allergies'] as List<dynamic>?)?.cast<String>() ?? ['Peanuts', 'Shellfish'],
    medicalConditions: json['medicalConditions'] ?? 'None',
    otherSensitivities: json['otherSensitivities'] ?? 'Lactose Intolerance',
  );

  /// Returns a comma-separated string of allergies for display
  String get allergiesDisplay => allergies.join(', ');
}
