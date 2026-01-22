import 'package:clothesecommerce/features/product/data/models/product_model.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  ProductLoaded(this.products);
}

class ProductLoadedOne extends ProductState {
  final Product product;
  ProductLoadedOne(this.product);
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}

class ProductAdded extends ProductState {
  // Product? products;
  // ProductAdded(this.products);
}

class ProductUpdated extends ProductState {}

class ProductDeleted extends ProductState {}
