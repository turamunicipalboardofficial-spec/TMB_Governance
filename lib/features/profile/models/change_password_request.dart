class ChangePasswordRequest {
  final String currentPassword;
  final String password;
  final String confirmPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'current_password': currentPassword,
    'password': password,
    'confirm_password': confirmPassword,
  };
}
