class CreateEmployeeRequest {
  final String firstname;
  final String lastname;
  final String email;
  final String password;
  final String dob;
  final String phoneNo;
  final int wardId;
  final String? locality;

  CreateEmployeeRequest({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
    required this.dob,
    required this.phoneNo,
    required this.wardId,
    this.locality,
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
    if (locality != null && locality!.isNotEmpty) {
      data['locality'] = locality;
    }
    return data;
  }
}