import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/features/login/presentation/pages/login_pages.dart';
import 'package:clothesecommerce/features/register/data/api/auth_api.dart';
import 'package:clothesecommerce/features/register/presentation/widget/custom_button.dart';
import 'package:clothesecommerce/features/register/presentation/widget/custom_container_register.dart';
import 'package:clothesecommerce/features/register/presentation/widget/custom_text_field.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/register_cubit.dart';
import '../../data/models/register_request.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key, required this.dio}) : super(key: key);
  Dio dio;
  static String nameScreen = 'RegisterScreen';

  @override
  State<RegisterPage> createState() => _RegisterPageState(dio: dio);
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  _RegisterPageState({required this.dio});
  final _formKey = GlobalKey<FormState>();
  static String nameScreen = 'RegisterScreen';

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  int _role = 1;

  @override
  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Dio dio;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RepositoryProvider(
      create: (_) => AuthApiRegister(dio),
      child: BlocProvider(
        create: (context) => RegisterCubit(context.read<AuthApiRegister>()),
        child: Scaffold(
          backgroundColor: Colors.white,

          body: BlocConsumer<RegisterCubit, RegisterState>(
            listener: (context, state) {
              if (state is RegisterSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } else if (state is RegisterFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.error}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
                print('${state.error}');
              }
            },
            builder: (context, state) {
              if (state is RegisterLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: context.watch<AppColors>().primaryColor,
                  ),
                );
              }

              return Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    CustomContainerRegister(),

                    SizedBox(height: 50),

                    // UserName
                    CustomTextField(
                      validate: 'أدخل اسم المستخدم',
                      icon: Icons.person,
                      controller: _userNameController,
                      label: 'اسم المستخدم',
                    ),
                    const SizedBox(height: 16),

                    // Email
                    CustomTextField(
                      validate: "أدخل الإيميل",
                      icon: Icons.email,
                      controller: _emailController,
                      label: 'الإيميل',
                      type: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Full Name
                    CustomTextField(
                      validate: "أدخل الاسم الكامل",
                      icon: Icons.badge,
                      controller: _fullNameController,
                      label: 'الاسم الكامل',
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
                    const SizedBox(height: 16),

                    // Confirm Password
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 20,
                      ),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.grey),
                          labelText: 'تأكيد كلمة المرور',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: context.watch<AppColors>().primaryColor,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: context.watch<AppColors>().primaryColor,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'أدخل تأكيد كلمة المرور';
                          }
                          if (value != _passwordController.text) {
                            return 'غير متطابقة مع كلمة المرور';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Role Dropdown
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 20,
                      ),
                      child: DropdownButtonFormField<int>(
                        value: _role,
                        decoration: InputDecoration(
                          labelText: 'نوع الحساب',
                          labelStyle: TextStyle(
                            color: context.watch<AppColors>().primaryColor,
                          ),
                          prefixIcon: Icon(
                            Icons.group,
                            color: context.watch<AppColors>().primaryColor,
                          ),

                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: context.watch<AppColors>().primaryColor,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(
                              'مسؤول',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text(
                              'مستخدم',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _role = val;
                            });
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Register Button with animation on press
                    CustomButton(
                      title: 'إنشاء الحساب',
                      ontap: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final request = RegisterRequest(
                            userName: _userNameController.text.trim(),
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                            confirmPassword: _confirmPasswordController.text,
                            fullName: _fullNameController.text.trim(),
                            role: _role,
                          );
                          context.read<RegisterCubit>().register(request);
                          Navigator.pushNamed(context, LoginPage.nameScreen);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ' هل لديك حساب بالفعل؟',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, LoginPage.nameScreen);
                          },
                          child: Text(
                            'سجل دخول ',
                            style: TextStyle(
                              color: context.watch<AppColors>().primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
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
//******************************************************************

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 4,
      size.height - 10,
      size.width / 2,
      size.height - 40,
    );
    path.quadraticBezierTo(
      3 / 4 * size.width,
      size.height - 80,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
