import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/api/auth_api.dart';
import '../../data/models/register_request.dart';
import '../../data/models/register_response.dart';

part 'register_cubit_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthApiRegister authApi;

  RegisterCubit(this.authApi) : super(RegisterInitial());

  Future<void> register(RegisterRequest request) async {
    emit(RegisterLoading());
    try {
      final RegisterResponse response = await authApi.register(request);

      // حفظ البيانات في SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', request.userName);
      await prefs.setString('fullName', request.fullName);
      await prefs.setString('password', request.password);
      await prefs.setString('email', request.email);
      await prefs.setInt('role', request.role);

      emit(RegisterSuccess(response.message));
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}
