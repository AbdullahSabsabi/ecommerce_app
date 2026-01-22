// lib/presentation/cubit/login_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:clothesecommerce/features/register/data/api/auth_api.dart'
    hide AuthApiRegister;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/login_request.dart';
import 'package:clothesecommerce/features/login/data/api/api_login.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthApiLogin authApi;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  LoginCubit(this.authApi) : super(LoginInitial());

  Future<void> login(
    LoginRequest request, {
    required String userName,
    required String password,
    required String userNameOrEmail,
  }) async {
    emit(LoginLoading());

    final request = LoginRequest(
      userName: userName,
      password: password,
      userNameOrEmail: userNameOrEmail,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', request.userName);
    await prefs.setString('fullName', request.userNameOrEmail);
    await prefs.setString('password', request.password);

    try {
      final res = await authApi.login(request);
      final token = res.token;
      await _storage.write(key: 'token', value: token);

      // هنا ممكن تخزن التوكن في secure storage لو تحب
      // مثال (تعليق): await FlutterSecureStorage().write(key: 'jwt', value: token);

      emit(LoginSuccess(token));
    } on DioError catch (e) {
      // نتأكد نعرض رسالة مفهومة للمستخدم
      String msg = 'خطأ غير معروف';
      if (e.error != null &&
          e.error is String &&
          (e.error as String).isNotEmpty) {
        msg = e.error as String;
      } else if (e.response != null && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null)
          msg = data['message'].toString();
        else
          msg = data.toString();
      } else if (e.type == DioErrorType.connectionTimeout ||
          e.type == DioErrorType.sendTimeout ||
          e.type == DioErrorType.receiveTimeout) {
        msg = 'انتهت مهلة الاتصال بالخادم. حاول لاحقاً.';
      } else if (e.type == DioErrorType.connectionError) {
        msg = 'فشل الاتصال بالخادم. تأكد من إعدادات الشبكة.';
      }
      emit(LoginFailure(msg));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
