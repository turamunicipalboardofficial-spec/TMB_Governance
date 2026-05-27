class LoginResponse {
  final String status;
  final String accessToken;
  final String tokenType;
  final String role;
  final String message;
  final UserDetails userDetails;

  LoginResponse({
    required this.status,
    required this.accessToken,
    required this.tokenType,
    required this.role,
    required this.message,
    required this.userDetails,
  });

  LoginResponse.fromJson(Map<String, dynamic> json)
    : status = json['status'] ?? '',
      accessToken = json['access_token'] ?? '',
      tokenType = json['token_type'] ?? '',
      role = json['role'] ?? '',
      message = json['message'] ?? '',
      userDetails = UserDetails.fromJson(json['user_details'] ?? {});
}

class UserDetails {
  final String firstname;
  final String lastname;
  final String email;
  final String phoneNo;
  final String dob;

  UserDetails({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phoneNo,
    required this.dob,
  });

  UserDetails.fromJson(Map<String, dynamic> json)
    : firstname = json['firstname'] ?? '',
      lastname = json['lastname'] ?? '',
      email = json['email'] ?? '',
      phoneNo = json['phone_no'] ?? '',
      dob = json['dob'] ?? '';

  Map<String, dynamic> toJson() => {
    'firstname': firstname,
    'lastname': lastname,
    'email': email,
    'phone_no': phoneNo,
    'dob': dob,
  };
}
