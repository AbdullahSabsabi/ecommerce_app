// lib/data/models/login_request.dart
class LoginRequest {
  final String userName;
  final String password;
  final String userNameOrEmail;

  LoginRequest({
    required this.userName,
    required this.password,
    this.userNameOrEmail = '',
  });

  Map<String, dynamic> toJson() => {
    "userName": userName,
    "password": password,
    "userNameOrEmail": userNameOrEmail,
  };
}
