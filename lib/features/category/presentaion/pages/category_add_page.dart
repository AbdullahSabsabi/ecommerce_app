import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/core/network/dio_client.dart';
import 'package:clothesecommerce/features/category/data/api/category_api.dart';
import 'package:clothesecommerce/features/category/data/models/category_model.dart';
import 'package:clothesecommerce/features/category/presentaion/widget/custom_elevated-button.dart';
import 'package:clothesecommerce/features/category/presentaion/widget/custom_field.dart';
import 'package:clothesecommerce/features/login/presentation/pages/login_pages.dart';
import 'package:clothesecommerce/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/category_cubit.dart';
// لو عندك ملف DioClient

class CategoryAddPage extends StatefulWidget {
  const CategoryAddPage({super.key});
  static String nameScreen = 'CategoryAddPage';

  @override
  State<CategoryAddPage> createState() => _CategoryAddPageState();
}

class _CategoryAddPageState extends State<CategoryAddPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';

  late final CategoryCubit _categoryCubit;

  @override
  void initState() {
    super.initState();
    final dio = DioClient.create();
    _categoryCubit = CategoryCubit(CategoryApi(dio));
  }

  @override
  void dispose() {
    _categoryCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _categoryCubit,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text("إضافة فئة", style: TextStyle(color: Colors.white)),
          backgroundColor: context.watch<AppColors>().primaryColor,
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 30),
              CustomField(
                onsaved: (value) => _name = value!,
                label: 'اسم الفئة',
              ),

              CustomField(
                onsaved: (value) => _description = value ?? '',
                label: 'الوصف',
              ),

              const SizedBox(height: 50),
              CustomElevatedButton(
                onpressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final category = Category(
                      categoryId: 0,
                      name: _name,
                      description: _description,
                      products: [],
                    );

                    _categoryCubit.addCategory(category);
                    await _categoryCubit.fetchCategories();

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      CategoryPage.nameScreen,
                      (route) => route.settings.name == LoginPage.nameScreen,
                    );
                  }
                },
                title: 'إضافة',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
