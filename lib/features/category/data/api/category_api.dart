import 'package:clothesecommerce/features/category/data/models/category_model.dart';
import 'package:dio/dio.dart';

class CategoryApi {
  final Dio _dio;

  CategoryApi(this._dio);

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('Category');
      if (response.statusCode == 200) {
        final data = await response.data as List<dynamic>;
        return await data.map((c) => Category.fromJson(c)).toList();
      } else if (response.statusCode == 404) {
        // لو رجع 404 نعتبر ما في فئات ونرجع قائمة فارغة
        return [];
      } else {
        throw Exception(
          'Failed to load categories, status code: ${response.statusCode}',
        );
      }
    } on DioError catch (e) {
      if (e.response?.statusCode == 404) {
        // لو خطأ 404 من Dio نرجع قائمة فارغة
        return [];
      } else {
        rethrow;
      }
    }
  }

  Future<void> addCategory(Category category) async {
    final response = await _dio.post('Category', data: category.toJson());

    if (response.statusCode != 201) {
      throw Exception('Failed to add category');
    }
  }

  Future<void> updateCategory(int id, Category category) async {
    final response = await _dio.put('Category/$id', data: category.toJson());

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('فشل تعديل الفئة');
    }
  }

  Future<void> deleteCategory(int id) async {
    final response = await _dio.delete('Category/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('فشل حذف الفئة');
    }
  }

  Future<Category> getCategoryById(int id) async {
    final response = await _dio.get('Category/$id');

    if (response.statusCode == 200) {
      return Category.fromJson(response.data);
    } else {
      throw Exception("فشل في جلب الفئة");
    }
  }
}
