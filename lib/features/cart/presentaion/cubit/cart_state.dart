import 'package:clothesecommerce/features/cart/data/models/cart_model.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final double totalPrice;

  CartLoaded(this.items)
    : totalPrice = items.fold(0, (sum, item) => sum + item.totalPrice);
}

class CartError extends CartState {
  final String message;
  CartError(this.message);
}
