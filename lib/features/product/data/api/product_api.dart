import 'dart:io';

import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ProductApi {
  final Dio _dio;

  ProductApi(this._dio);

  Future<List<Product>> getProducts() async {
    final response = await _dio.get('Products');

    if (response.statusCode == 200) {
      final List data = response.data as List;
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('فشل في جلب المنتجات');
    }
  }

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final response = await _dio.get(
      'Products/ByCategory/$categoryId',
      options: Options(
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    print("Status code: ${response.statusCode}");
    print("Response data: ${response.data}");

    if (response.statusCode == 200) {
      if (response.data is List) {
        final List data = response.data as List;
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        return [];
      }
    } else if (response.statusCode == 404) {
      return []; // الفئة موجودة بس ما فيها منتجات
    } else {
      throw Exception('فشل في جلب منتجات الفئة: ${response.statusMessage}');
    }
  }

  Future<Product> getProductById(int id) async {
    final response = await _dio.get('Products/$id');

    if (response.statusCode == 200) {
      return Product.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب المنتج');
    }
  }

  Future<void> addProduct(Product product) async {
    final response = await _dio.post('Products', data: product.toJson());

    if (response.statusCode != 201) {
      throw Exception('فشل في إضافة المنتج');
    }
  }

  Future<void> updateProduct(int id, Product product) async {
    final response = await _dio.put('Products/$id', data: product.toJson());

    if (response.statusCode != 204) {
      throw Exception('فشل في تعديل المنتج');
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await _dio.delete('Products/$id');

    if (response.statusCode != 204) {
      throw Exception('فشل في حذف المنتج');
    }
  }

  Future<String?> uploadProductImage(File imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          imageFile.path,
          filename: "upload.jpg",
        ),
      });

      final response = await _dio.post('Products/UploadImage', data: formData);
      print(response.data); // شوف الرد

      if (response.statusCode == 200) {
        // لأن المفتاح اسمو imageUrl
        return response.data['imageUrl'];
      } else {
        throw Exception('فشل في رفع الصورة');
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
