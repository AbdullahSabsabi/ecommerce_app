import 'package:clothesecommerce/features/product/data/models/product_model.dart';

abstract class FavoriteState {}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<Product> favorites;
  FavoriteLoaded({required this.favorites});
}

class FavoriteError extends FavoriteState {
  final String message;
  FavoriteError(this.message);
}
