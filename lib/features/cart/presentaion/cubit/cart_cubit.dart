import 'dart:convert';
import 'package:clothesecommerce/features/cart/data/models/cart_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial()) {
    loadCart(); // 🔹 تحميل السلة عند إنشاء الـCubit
  }

  // ==================== دوال إدارة السلة ====================
  void addProduct(CartItem newItem) {
    if (state is CartLoaded) {
      final currentItems = List<CartItem>.from((state as CartLoaded).items);
      final index = currentItems.indexWhere(
        (item) => item.product.productID == newItem.product.productID,
      );
      if (index != -1) {
        currentItems[index].quantity += newItem.quantity;
      } else {
        currentItems.add(newItem);
      }
      saveCart(currentItems); // 🔹 حفظ السلة بعد التعديل
      emit(CartLoaded(currentItems));
    } else {
      saveCart([newItem]);
      emit(CartLoaded([newItem]));
    }
  }

  void removeProduct(int productId) {
    if (state is CartLoaded) {
      final currentItems = List<CartItem>.from((state as CartLoaded).items);
      currentItems.removeWhere((item) => item.product.productID == productId);
      saveCart(currentItems); // 🔹 حفظ السلة بعد الحذف
      emit(CartLoaded(currentItems));
    }
  }

  void updateQuantity(int productId, int quantity) {
    if (state is CartLoaded) {
      final currentItems = List<CartItem>.from((state as CartLoaded).items);
      final index = currentItems.indexWhere(
        (item) => item.product.productID == productId,
      );
      if (index != -1) {
        currentItems[index].quantity = quantity;
      }
      saveCart(currentItems); // 🔹 حفظ السلة بعد التحديث
      emit(CartLoaded(currentItems));
    }
  }

  // ==================== دوال SharedPreferences ====================
  Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final data = items.map((e) => e.toJson()).toList();
    await prefs.setString('cart', jsonEncode(data));
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cart');
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      final items = decoded.map((e) => CartItem.fromJson(e)).toList();
      emit(CartLoaded(items));
    } else {
      emit(CartLoaded([]));
    }
  }

  Future<void> clearCart() async {
    emit(CartLoaded([]));
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart');
  }
}
