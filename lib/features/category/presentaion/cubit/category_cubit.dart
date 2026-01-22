import 'package:clothesecommerce/features/category/data/models/category_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_state.dart';
import '../../data/api/category_api.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryApi categoryApi;

  CategoryCubit(this.categoryApi) : super(CategoryInitial());

  Future<void> fetchCategories() async {
    try {
      emit(CategoryLoading());
      final data = await categoryApi.getCategories();
      emit(CategoryLoaded(data));
    } catch (e) {
      emit(CategoryError(e.toString()));
      print(e.toString());
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      emit(CategoryLoading());
      await categoryApi.addCategory(category);

      emit(CategoryAdded());
      await fetchCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
      print(e.toString());
    }
  }

  Future<void> editCategory(int id, Category category) async {
    emit(CategoryLoading()); // علشان الواجهة تعرف إن في عملية جارية
    try {
      await categoryApi.updateCategory(id, category);
      await fetchCategories(); // نعيد تحميل القائمة بعد التعديل
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      emit(CategoryLoading());
      await categoryApi.deleteCategory(id);
      // إعادة تحميل الفئات بعد الحذف
      await fetchCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  void fetchCategoryById(int id) async {
    try {
      emit(CategoryLoading());
      final category = await categoryApi.getCategoryById(id);

      emit(CategoryLoadedOne(category: category)); // حالة مخصصة لعرض فئة واحدة
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
