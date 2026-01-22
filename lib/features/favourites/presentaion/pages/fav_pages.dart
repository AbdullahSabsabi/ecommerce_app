import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/features/cart/data/models/cart_model.dart';
import 'package:clothesecommerce/features/cart/presentaion/cubit/cart_cubit.dart';
import 'package:clothesecommerce/features/favourites/data/api/fav_api.dart';
import 'package:clothesecommerce/features/favourites/presentaion/cubit/fav_cubit.dart';
import 'package:clothesecommerce/features/favourites/presentaion/cubit/fav_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesPage extends StatelessWidget {
  final Dio dio;
  const FavoritesPage({super.key, required this.dio});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoriteCubit(FavoriteApi(dio))..loadFavorites(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: context.watch<AppColors>().primaryColor,
          foregroundColor: Colors.white,
          title: Text('المفضلة', style: TextStyle(color: Colors.white)),
        ),
        body: Stack(
          children: [
            // خلفية متدرجة
            Container(color: Colors.white),
            SafeArea(
              child: Column(
                children: [
                  // AppBar

                  // المحتوى
                  Expanded(
                    child: BlocBuilder<FavoriteCubit, FavoriteState>(
                      builder: (context, state) {
                        if (state is FavoriteLoading) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: context.watch<AppColors>().primaryColor,
                            ),
                          );
                        } else if (state is FavoriteLoaded) {
                          if (state.favorites.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.favorite_border,
                                    size: 120,
                                    color: context
                                        .watch<AppColors>()
                                        .primaryColor
                                        .withOpacity(0.5),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "المفضلة فارغة!",
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "ابدأ بإضافة منتجاتك المفضلة الآن.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // عرض المنتجات
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            itemCount: state.favorites.length,
                            itemBuilder: (context, index) {
                              final product = state.favorites[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: context
                                    .watch<AppColors>()
                                    .primaryColor
                                    .withOpacity(0.6),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child:
                                        (product.imageUrl.isEmpty ||
                                            product.imageUrl.toLowerCase() ==
                                                "null")
                                        ? const Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.white70,
                                          )
                                        : Image.network(
                                            product.imageUrl,
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  size: 50,
                                                  color: Colors.white70,
                                                ),
                                          ),
                                  ),
                                  title: Text(
                                    product.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${product.price.toStringAsFixed(2)} ل.س",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // زر إضافة للسلة
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_shopping_cart,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          final cartItem = CartItem(
                                            product: product,
                                            quantity: 1,
                                          );
                                          context.read<CartCubit>().addProduct(
                                            cartItem,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "${product.name} تمت إضافته إلى السلة",
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      // زر حذف من المفضلة
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () async {
                                          context
                                              .read<FavoriteCubit>()
                                              .removeFavorite(
                                                product.productID,
                                              );
                                          await context
                                              .read<FavoriteCubit>()
                                              .loadFavorites();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "${product.name} تمت إزالته من المفضلة",
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } else if (state is FavoriteError) {
                          return Center(
                            child: Text(
                              state.message,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
