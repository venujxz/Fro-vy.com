/// Represents a user's personal profile information.
class UserProfile {
  String name;
  String email;
  String phone;
  String dob;
  String gender;

  UserProfile({
    this.name = 'John Doe',
    this.email = 'john.doe@example.com',
    this.phone = '+94 77 123 4567',
    this.dob = '2000-11-22',
    this.gender = 'male',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'dob': dob,
    'gender': gender,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? 'John Doe',
    email: json['email'] ?? 'john.doe@example.com',
    phone: json['phone'] ?? '+94 77 123 4567',
    dob: json['dob'] ?? '2000-11-22',
    gender: json['gender'] ?? 'male',
  );
}
