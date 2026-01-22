import 'package:dio/dio.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';

class AuthApiRegister {
  final Dio _dio;

  AuthApiRegister(this._dio);

  Future<RegisterResponse> register(RegisterRequest request) async {
    final response = await _dio.post('Auth/Register', data: request.toJson());

    if (response.statusCode == 200 || response.statusCode == 201) {
      return RegisterResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to register: ${response.statusCode}');
      //print(response.data);
    }
  }
}
