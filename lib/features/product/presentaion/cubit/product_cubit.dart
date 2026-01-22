import 'dart:io';
import 'package:clothesecommerce/features/product/data/api/product_api.dart';
import 'package:clothesecommerce/features/product/data/models/product_model.dart';
import 'package:clothesecommerce/features/product/presentaion/cubit/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductApi productApi;

  ProductCubit(this.productApi) : super(ProductInitial());

  Future<void> fetchProducts() async {
    try {
      emit(ProductLoading());

      final data = await productApi.getProducts();
      emit(ProductLoaded(data));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> fetchProductsByCategory(int categoryId) async {
    try {
      emit(ProductLoading());
      final data = await productApi.getProductsByCategory(categoryId);
      emit(ProductLoaded(data));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> fetchProductById(int id) async {
    try {
      emit(ProductLoading());
      final product = await productApi.getProductById(id);
      emit(ProductLoadedOne(product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> addProduct(Product product, {File? imageFile}) async {
    try {
      emit(ProductLoading());

      if (imageFile != null) {
        final imageUrl = await productApi.uploadProductImage(imageFile);
        if (imageUrl != null) {
          product = product.copyWith(imageUrl: imageUrl);
        }
      }

      await productApi.addProduct(product);
      await fetchProductsByCategory(product.categoryID);
      emit(ProductAdded());
      //  await productApi.updateProduct(id, updatedProduct);

      // // إعادة تحميل المنتجات حسب الفئة
      // await fetchProductsByCategory(updatedProduct.categoryID);

      // emit(ProductUpdated());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> deleteProduct(int id, {required int categoryId}) async {
    try {
      emit(ProductLoading());
      await productApi.deleteProduct(id);
      await fetchProductsByCategory(categoryId);
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      emit(ProductLoading());
      final imageUrl = await productApi.uploadProductImage(imageFile);
      return imageUrl;
    } catch (e) {
      emit(ProductError('فشل رفع الصورة: $e'));
      return null;
    }
  }

  // تعديل المنتج مع دعم الصورة الجديدة
  Future<void> editProduct(int id, Product product, {File? imageFile}) async {
    try {
      emit(ProductLoading());

      Product updatedProduct = product;

      // رفع الصورة أولًا إذا اختار المستخدم صورة جديدة
      if (imageFile != null) {
        final imageUrl = await productApi.uploadProductImage(imageFile);
        if (imageUrl != null) {
          updatedProduct = product.copyWith(imageUrl: imageUrl);
        }
      }

      // تعديل المنتج باستخدام رابط الصورة الجديد
      await productApi.updateProduct(id, updatedProduct);

      // إعادة تحميل المنتجات حسب الفئة
      await fetchProductsByCategory(updatedProduct.categoryID);

      emit(ProductUpdated());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void decreaseStock(int productId) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;

      final updatedProducts = currentState.products.map((product) {
        if (product.productID == productId && product.stockQuantity > 0) {
          return product.copyWith(stockQuantity: product.stockQuantity - 1);
        }
        return product;
      }).toList();

      emit(ProductLoaded(updatedProducts));
    }
  }
}
