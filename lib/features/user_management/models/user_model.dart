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

    // MySQL/Laravel returns is_active as an int (1/0), not a bool.
    // Handle both int and bool forms safely to avoid a runtime type error.
    bool? parseIsActive(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value == '1' || value.toLowerCase() == 'true';
      return null;
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
      isActive: parseIsActive(json['is_active']),
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