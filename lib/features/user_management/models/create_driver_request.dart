class CreateDriverRequest {
  final String firstname;
  final String lastname;
  final String email;
  final String password;
  final String dob;
  final String phoneNo;
  final int wardId;
  final String? locality;
  final String driverLicenseNumber;
  final String licenseExpiry;
  final int? truckId;

  CreateDriverRequest({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
    required this.dob,
    required this.phoneNo,
    required this.wardId,
    this.locality,
    required this.driverLicenseNumber,
    required this.licenseExpiry,
    this.truckId,
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
      'driver_license_number': driverLicenseNumber,
      'license_expiry': licenseExpiry,
    };
    if (locality != null && locality!.isNotEmpty) {
      data['locality'] = locality;
    }
    if (truckId != null) {
      data['truck_id'] = truckId;
    }
    return data;
  }
}