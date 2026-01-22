import 'package:clothesecommerce/features/favourites/data/api/fav_api.dart';
import 'package:clothesecommerce/features/favourites/presentaion/cubit/fav_state.dart';
import 'package:clothesecommerce/features/product/data/models/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  final FavoriteApi api;
  FavoriteCubit(this.api) : super(FavoriteInitial());

  Future<void> loadFavorites() async {
    try {
      emit(FavoriteLoading());
      final favs = await api.getFavorites();
      emit(FavoriteLoaded(favorites: favs));
    } catch (e) {
      emit(FavoriteError("حدث خطأ أثناء تحميل المفضلة"));
    }
  }

  void addFavorite(int productId) async {
    try {
      await api.addFavorite(productId);
      loadFavorites();
      print('added');
    } catch (e) {
      emit(FavoriteError("حدث خطأ أثناء إضافة المنتج للمفضلة"));
    }
  }

  void removeFavorite(int productId) async {
    try {
      await api.removeFavorite(productId);

      // تحديث الحالة محلياً بدون انتظار API كامل
      if (state is FavoriteLoaded) {
        final currentFavorites = List<Product>.from(
          (state as FavoriteLoaded).favorites,
        );
        currentFavorites.removeWhere((p) => p.productID == productId);

        emit(FavoriteLoaded(favorites: currentFavorites));
      }

      print('removed');
    } catch (e) {
      emit(FavoriteError("حدث خطأ أثناء إزالة المنتج من المفضلة"));
    }
  }

  bool isFavorite(FavoriteState state, int productId) {
    if (state is FavoriteLoaded) {
      return state.favorites.any((fav) => fav.productID == productId);
    }
    return false;
  }
}
