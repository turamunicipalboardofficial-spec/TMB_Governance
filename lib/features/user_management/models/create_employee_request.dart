class CreateEmployeeRequest {
  final String firstname;
  final String lastname;
  final String email;
  final String password;
  final String dob;
  final String phoneNo;
  final int wardId;
  final int? localityId;
  final String? role;

  CreateEmployeeRequest({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
    required this.dob,
    required this.phoneNo,
    required this.wardId,
    this.localityId,
    this.role,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'password': password,
      'dob': dob,
      'phone_no': phoneNo,
      'ward_id': wardId,
    };
    if (localityId != null) {
      data['locality_id'] = localityId;
    }
    if (role != null) {
      data['role'] = role;
    }
    return data;
  }
}
