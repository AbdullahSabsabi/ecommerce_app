import 'package:clothesecommerce/features/product/data/models/product_model.dart';

class Category {
  final int categoryId;
  final String name;
  final String description;
  final List<Product> products;

  Category({
    required this.categoryId,
    required this.name,
    required this.description,
    required this.products,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final productsJson = json['products'] as List<dynamic>? ?? [];
    final productsList = productsJson.map((p) => Product.fromJson(p)).toList();

    return Category(
      categoryId: json['category_ID'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      products: productsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "category_ID":
          categoryId, // عادةً في POST للإضافة ما تعطي id لأنه يتولد تلقائياً من السيرفر
      'name': name,
      'description': description,
      // إذا كنت تحتاج إرسال المنتجات مع الفئة في الـ API، قم بإلغاء تعليق السطر التالي:
      // 'products': products.map((p) => p.toJson()).toList(),
    };
  }
}
