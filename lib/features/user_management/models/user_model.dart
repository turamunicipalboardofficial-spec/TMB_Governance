class UserModel {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String? phoneNo;
  final String? dob;
  final String role;
  final int? wardId;
  final String? locality;
  final bool? isActive;

  UserModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.phoneNo,
    this.dob,
    required this.role,
    this.wardId,
    this.locality,
    this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // locality can be int or String from API, normalize to String?
    String? parseLocality(dynamic value) {
      if (value == null) return null;
      return value.toString();
    }

    return UserModel(
      id: json['id'] ?? 0,
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      phoneNo: json['phone_no']?.toString(),
      dob: json['dob']?.toString(),
      role: json['role'] ?? '',
      wardId: json['ward_id'] is int
          ? json['ward_id']
          : int.tryParse(json['ward_id']?.toString() ?? ''),
      locality: parseLocality(json['locality']),
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'phone_no': phoneNo,
      'dob': dob,
      'role': role,
      'ward_id': wardId,
      'locality': locality,
      'is_active': isActive,
    };
  }

  String get fullName => '$firstname $lastname';
}