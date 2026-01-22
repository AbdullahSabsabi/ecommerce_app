import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/features/category/data/models/category_model.dart';
import 'package:clothesecommerce/features/category/presentaion/cubit/category_cubit.dart';
import 'package:clothesecommerce/features/category/presentaion/widget/custom_elevated-button.dart';
import 'package:clothesecommerce/features/category/presentaion/widget/custom_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryEditScreen extends StatefulWidget {
  final Category category;

  const CategoryEditScreen({super.key, required this.category});

  @override
  State<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends State<CategoryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late int _categoryId;
  late String name;
  late String description;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.category.categoryId;
    name = widget.category.name;
    description = widget.category.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<CategoryCubit>(), // نفس الكيوبت من الشاشة السابقة
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            "تعديل الفئة",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: context.watch<AppColors>().primaryColor,
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 30),
              CustomField(
                label: 'اسم الفئة',
                onsaved: (value) => name = value!,
                init: name,
              ),

              CustomField(
                label: 'الوصف',
                onsaved: (value) => description = value!,
                init: description,
              ),
              SizedBox(height: 50),
              CustomElevatedButton(
                title: 'حفظ التعديلات',
                onpressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final updatedCategory = Category(
                      categoryId: _categoryId,
                      name: name,
                      description: description,
                      products: [],
                    );

                    context.read<CategoryCubit>().editCategory(
                      widget.category.categoryId,
                      updatedCategory,
                    );

                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
