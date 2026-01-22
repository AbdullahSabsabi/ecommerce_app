import 'dart:io';
import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/core/network/dio_client.dart';
import 'package:clothesecommerce/features/product/data/models/product_model.dart';
import 'package:clothesecommerce/features/product/presentaion/cubit/product_cubit.dart';
import 'package:clothesecommerce/features/product/presentaion/pages/products_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ProductAddPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const ProductAddPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ProductAddPage> createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  final dio = DioClient.create();
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _imageUrl = '';
  int _stock = 0;
  double _price = 0;
  String _desc = '';
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text(
                  "كاميرا",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    setState(() => _selectedImage = File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text(
                  "المعرض",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() => _selectedImage = File(image.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration customInput(String label) {
    return InputDecoration(
      labelStyle: TextStyle(color: const Color.fromARGB(255, 105, 104, 104)),

      labelText: label,

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: context.watch<AppColors>().primaryColor),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.black),
      ),

      filled: true,
      fillColor: context.watch<AppColors>().primaryColor.withOpacity(0.1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text("إضافة منتج", style: const TextStyle()),
        centerTitle: true,
        elevation: 2,
        backgroundColor: context.watch<AppColors>().primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              SizedBox(height: 20),
              // اسم المنتج
              TextFormField(
                decoration: customInput('اسم المنتج'),
                validator: (v) => v == null || v.isEmpty ? 'أدخل الاسم' : null,
                onSaved: (v) => _name = v!.trim(),
              ),
              const SizedBox(height: 16),

              // اختيار الصورة
              GestureDetector(
                onTap: () => pickImage(context),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: context.watch<AppColors>().primaryColor.withOpacity(
                      0.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.add_a_photo,
                              size: 48,
                              color: Color.fromARGB(255, 103, 103, 103),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "اضغط لاختيار صورة",
                              style: TextStyle(
                                color: Color.fromARGB(255, 126, 125, 125),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // الكمية
              TextFormField(
                decoration: customInput('الكمية في المخزون'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'أدخل الكمية' : null,
                onSaved: (v) => _stock = int.tryParse(v ?? '0') ?? 0,
              ),
              const SizedBox(height: 16),

              // السعر
              TextFormField(
                decoration: customInput('السعر'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'أدخل السعر' : null,
                onSaved: (v) => _price = double.tryParse(v ?? '0') ?? 0,
              ),
              const SizedBox(height: 16),

              // الوصف
              TextFormField(
                decoration: customInput('الوصف'),
                maxLines: 4,
                onSaved: (v) => _desc = v?.trim() ?? '',
              ),
              const SizedBox(height: 24),

              // زر الإضافة
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context
                        .watch<AppColors>()
                        .primaryColor
                        .withOpacity(0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'إضافة المنتج',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      var product = Product(
                        productID: 0,
                        name: _name,
                        imageUrl: _imageUrl,
                        stockQuantity: _stock,
                        price: _price,
                        description: _desc,
                        categoryID: widget.categoryId,
                        category: null,
                      );

                      await context.read<ProductCubit>().addProduct(
                        product,
                        imageFile: _selectedImage,
                      );
                      await context
                          .read<ProductCubit>()
                          .fetchProductsByCategory(widget.categoryId);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductListByCategoryPage(
                            dio: dio,
                            categoryId: widget.categoryId,
                            categoryName: widget.categoryName,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
