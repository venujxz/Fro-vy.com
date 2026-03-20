class UserModel {
  final String uid;
  final String name;
  final String email;
  final String gender;
  final String dob;
  final List<String> conditions;
  final List<String> foodAllergies;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.gender,
    required this.dob,
    this.conditions = const [],
    this.foodAllergies = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'] ?? '',
      dob: map['dob'] ?? '',
      conditions: List<String>.from(map['conditions'] ?? []),
      foodAllergies: List<String>.from(map['foodAllergies'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'gender': gender,
    'dob': dob,
    'conditions': conditions,
    'foodAllergies': foodAllergies,
  };
}
