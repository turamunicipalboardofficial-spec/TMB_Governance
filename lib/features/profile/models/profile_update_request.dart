class ProfileUpdateRequest {
  final String firstname;
  final String lastname;
  final String dob;
  final String phoneNo;
  final String email;

  ProfileUpdateRequest({
    required this.firstname,
    required this.lastname,
    required this.dob,
    required this.phoneNo,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
    'firstname': firstname,
    'lastname': lastname,
    'dob': dob,
    'phone_no': phoneNo,
    'email': email,
  };
}
