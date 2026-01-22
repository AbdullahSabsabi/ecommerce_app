import 'package:clothesecommerce/features/category/data/models/category_model.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  CategoryLoaded(this.categories);
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}

class CategoryAdded extends CategoryState {}

class CategoryLoadedOne extends CategoryState {
  final Category category;
  CategoryLoadedOne({required this.category});
}
