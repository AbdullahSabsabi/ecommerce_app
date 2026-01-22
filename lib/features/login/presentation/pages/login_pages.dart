import 'package:clothesecommerce/core/network/is_admin.dart';
import 'package:clothesecommerce/features/cart/presentaion/cubit/cart_cubit.dart';
import 'package:clothesecommerce/features/favourites/presentaion/cubit/fav_cubit.dart';
import 'package:clothesecommerce/features/login/data/api/api_login.dart';
import 'package:clothesecommerce/features/login/presentation/widget/custom_container_login.dart';
import 'package:clothesecommerce/features/register/presentation/pages/register_page.dart';
import 'package:clothesecommerce/features/register/presentation/widget/custom_button.dart';
import 'package:clothesecommerce/features/register/presentation/widget/custom_text_field.dart';
import 'package:clothesecommerce/home_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../cubit/login_cubit.dart';
import '../../../login/data/models/login_request.dart';
import 'package:clothesecommerce/constant.dart'; // اللون الرئيسي وغيره

class LoginPage extends StatefulWidget {
  final Dio dio;

  const LoginPage({Key? key, required this.dio}) : super(key: key);
  static String nameScreen = 'LoginScreen';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static String nameScreen = 'LoginScreen';
  final _formKey = GlobalKey<FormState>();
  final _secureStorage = const FlutterSecureStorage();

  final TextEditingController _userNameOrEmailController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _userNameOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => AuthApiLogin(widget.dio),
      child: BlocProvider(
        create: (context) => LoginCubit(context.read<AuthApiLogin>()),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: BlocConsumer<LoginCubit, LoginState>(
            listener: (context, state) async {
              if (state is LoginSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تسجيل الدخول بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );

                try {
                  _secureStorage.write(key: 'jwt', value: state.token);
                } catch (e) {
                  print('*********************************${e.toString()}');
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryPage(dio: widget.dio),
                  ),
                );
                context.read<CartCubit>().clearCart();
                context.read<FavoriteCubit>().loadFavorites();

                final user = await AuthHelper.getUserFromToken();

                // هنا ممكن تنقل للصفحة الرئيسية أو تحفظ التوكن
              } else if (state is LoginFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('حدث خطأ: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
                print('حدث خطأ: ${state.message}');
              }
            },
            builder: (context, state) {
              if (state is LoginLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: context.watch<AppColors>().primaryColor,
                  ),
                );
              }

              return Form(
                key: _formKey,
                child: ListView(
                  children: [
                    CustomContainerLogin(),
                    const SizedBox(height: 100),

                    // UserNameOrEmail
                    CustomTextField(
                      validate: "أدخل اسم المستخدم أو الإيميل",
                      icon: Icons.person,
                      controller: _userNameOrEmailController,
                      label: 'اسم المستخدم أو الإيميل',
                    ),
                    const SizedBox(height: 16),

                    // Password
                    CustomTextField(
                      validate: "أدخل كلمة المرور",
                      ispass: true,
                      icon: Icons.password,
                      controller: _passwordController,
                      label: 'كلمة المرور',
                    ),
                    const SizedBox(height: 75),

                    CustomButton(
                      title: 'تسجيل الدخول',
                      ontap: () {
                        if (_formKey.currentState!.validate()) {
                          final request = LoginRequest(
                            userName: _userNameOrEmailController.text.trim(),
                            userNameOrEmail: _userNameOrEmailController.text
                                .trim(),
                            password: _passwordController.text,
                          );
                          context.read<LoginCubit>().login(
                            request,
                            userName: _userNameOrEmailController.text,
                            password: _passwordController.text,
                            userNameOrEmail: _userNameOrEmailController.text,
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ' ليس لديك حساب ؟',

                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              RegisterPage.nameScreen,
                            );
                          },
                          child: Text(
                            'أنشئ حساب ',
                            style: TextStyle(
                              color: context.watch<AppColors>().primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
