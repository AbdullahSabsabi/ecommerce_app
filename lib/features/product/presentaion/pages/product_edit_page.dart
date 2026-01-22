import 'dart:io';
import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/features/product/data/models/product_model.dart';
import 'package:clothesecommerce/features/product/presentaion/cubit/product_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ProductEditPage extends StatefulWidget {
  final Product product;
  const ProductEditPage({super.key, required this.product});

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late int _stock;
  late double _price;
  late String _desc;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _stock = widget.product.stockQuantity;
    _price = widget.product.price;
    _desc = widget.product.description;
  }

  Future<void> pickImage(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
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
                if (image != null)
                  setState(() => _selectedImage = File(image.path));
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
                if (image != null)
                  setState(() => _selectedImage = File(image.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration customInput(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: context.watch<AppColors>().primaryColor.withOpacity(0.1),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("تعديل المنتج"),
        centerTitle: true,
        elevation: 2,
        backgroundColor: context.watch<AppColors>().primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _name,
                decoration: customInput('اسم المنتج'),
                validator: (v) => v == null || v.isEmpty ? 'أدخل الاسم' : null,
                onSaved: (v) => _name = v!.trim(),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => pickImage(context),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: context.watch<AppColors>().primaryColor.withOpacity(
                      0.1,
                    ),
                    boxShadow: const [
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
                      : widget.product.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            widget.product.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(child: Icon(Icons.add_a_photo, size: 50)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _stock.toString(),
                decoration: customInput('الكمية في المخزون'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'أدخل الكمية' : null,
                onSaved: (v) => _stock = int.tryParse(v ?? '0') ?? 0,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _price % 1 == 0
                    ? _price.toInt().toString()
                    : _price.toString(),
                decoration: customInput('السعر'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => v == null || v.isEmpty ? 'أدخل السعر' : null,
                onSaved: (v) {
                  final normalized = v?.replaceAll(',', '.') ?? '0';
                  _price = double.tryParse(normalized) ?? 0;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _desc,
                decoration: customInput('الوصف'),
                maxLines: 4,
                onSaved: (v) => _desc = v?.trim() ?? '',
              ),
              const SizedBox(height: 24),
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
                    'حفظ التعديلات',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      Product updatedProduct = Product(
                        productID: widget.product.productID,
                        name: _name,
                        imageUrl: widget.product.imageUrl,
                        stockQuantity: _stock,
                        price: _price,
                        description: _desc,
                        categoryID: widget.product.categoryID,
                        category: widget.product.category,
                      );

                      // رفع الصورة الجديدة إذا اختار المستخدم
                      if (_selectedImage != null) {
                        final imageUrl = await context
                            .read<ProductCubit>()
                            .uploadImage(_selectedImage!);
                        if (imageUrl != null)
                          updatedProduct = updatedProduct.copyWith(
                            imageUrl: imageUrl,
                          );
                      }

                      // تعديل المنتج عبر Cubit
                      await context.read<ProductCubit>().editProduct(
                        widget.product.productID,
                        updatedProduct,
                      );

                      await context
                          .read<ProductCubit>()
                          .fetchProductsByCategory(widget.product.categoryID);

                      // await context.read<ProductCubit>().fetchProducts();

                      if (context.mounted) Navigator.pop(context, true);
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
