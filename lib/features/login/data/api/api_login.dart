// lib/data/api/auth_api.dart
import 'package:dio/dio.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthApiLogin {
  final Dio _dio;

  AuthApiLogin(this._dio);

  /// Login - returns LoginResponse on success
  /// On failure returns Response object so caller can inspect message/status
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      'Auth/Login',
      data: request.toJson(),
      options: Options(
        headers: {'Content-Type': 'application/json'},
        validateStatus: (status) => true, // نريد قراءة body حتى لو كان 400
      ),
    );

    if (response.statusCode == 200) {
      // متوقع JSON { "token": "..." }
      return LoginResponse.fromJson(response.data);
    } else {
      // رمي استثناء يحتوي على كل المعلومات عشان Cubit يتعامل ويعرض رسالة مفيدة
      String serverMessage = '';
      try {
        if (response.data is String) {
          serverMessage = response.data;
        } else if (response.data is Map && response.data['message'] != null) {
          serverMessage = response.data['message'].toString();
        } else if (response.data is Map) {
          serverMessage = response.data.toString();
        } else {
          serverMessage = 'Status: ${response.statusCode}';
        }
      } catch (_) {
        serverMessage = 'Status: ${response.statusCode}';
      }
      throw DioError(
        requestOptions: response.requestOptions,
        response: response,
        error: serverMessage,
        type: DioErrorType.badResponse,
      );
    }
  }
}
