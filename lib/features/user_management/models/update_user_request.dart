class UpdateUserRequest {
  final String? firstname;
  final String? lastname;
  final String? email;
  final String? password;
  final String? dob;
  final String? phoneNo;
  final int? wardId;
  final String? locality;
  final String? role;

  UpdateUserRequest({
    this.firstname,
    this.lastname,
    this.email,
    this.password,
    this.dob,
    this.phoneNo,
    this.wardId,
    this.locality,
    this.role,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (firstname != null && firstname!.isNotEmpty) data['firstname'] = firstname;
    if (lastname != null && lastname!.isNotEmpty) data['lastname'] = lastname;
    if (email != null && email!.isNotEmpty) data['email'] = email;
    if (password != null && password!.isNotEmpty) data['password'] = password;
    if (dob != null && dob!.isNotEmpty) data['dob'] = dob;
    if (phoneNo != null && phoneNo!.isNotEmpty) data['phone_no'] = phoneNo;
    if (wardId != null) data['ward_id'] = wardId;
    if (locality != null && locality!.isNotEmpty) data['locality'] = locality;
    if (role != null && role!.isNotEmpty) data['role'] = role;
    return data;
  }
}