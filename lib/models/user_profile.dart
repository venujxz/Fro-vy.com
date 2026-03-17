/// Represents a user's personal profile information.
class UserProfile {
  String name;
  String email;
  String phone;
  String dob;
  String gender;

  UserProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.dob = '',
    this.gender = '',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'dob': dob,
    'gender': gender,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    dob: json['dob'] ?? '',
    gender: json['gender'] ?? '',
  );
}
