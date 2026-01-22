import 'package:clothesecommerce/features/product/data/models/product_model.dart';
import 'package:dio/dio.dart';

class FavoriteApi {
  final Dio dio;
  FavoriteApi(this.dio);

  Future<List<Product>> getFavorites() async {
    try {
      final response = await dio.get('Favourites');

      // إذا البيانات موجودة ورجعت ليست فارغة
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List)
            .map((json) => Product.fromJson(json))
            .toList();
      } else {
        // لو البيانات فاضية
        return [];
      }
    } on DioError catch (e) {
      // إذا الخطأ 404 يعني لا يوجد عناصر مفضلة
      if (e.response?.statusCode == 404) {
        return [];
      }
      // أي خطأ آخر نعيد رميه
      rethrow;
    }
  }

  Future<void> addFavorite(int productId) async {
    await dio.post('Favourites/Add', data: {'productId': productId});
  }

  Future<void> removeFavorite(int productId) async {
    await dio.delete('Favourites/Remove', data: {'productId': productId});
  }
}
