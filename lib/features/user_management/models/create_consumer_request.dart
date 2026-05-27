class CreateConsumerRequest {
  final String firstname;
  final String lastname;
  final String email;
  final String password;
  final String dob;
  final String phoneNo;
  final int? wardId;
  final int? localityId;

  CreateConsumerRequest({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
    required this.dob,
    required this.phoneNo,
    this.wardId,
    this.localityId,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'password': password,
      'dob': dob,
      'phone_no': phoneNo,
    };
    if (wardId != null) {
      data['ward_id'] = wardId;
    }
    if (localityId != null) {
      data['locality_id'] = localityId;
    }
    return data;
  }
}