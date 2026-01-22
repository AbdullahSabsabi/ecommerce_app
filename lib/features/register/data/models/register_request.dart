class RegisterRequest {
  final String userName;
  final String email;
  final String password;
  final String confirmPassword;
  final String fullName;
  final int role;

  RegisterRequest({
    required this.userName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.fullName,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'fullName': fullName,
      'role': role,
    };
  }
}
