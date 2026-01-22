import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/core/network/is_admin.dart';
import 'package:clothesecommerce/features/cart/data/models/cart_model.dart';
import 'package:clothesecommerce/features/cart/presentaion/cubit/cart_cubit.dart';
import 'package:clothesecommerce/features/favourites/presentaion/cubit/fav_cubit.dart';
import 'package:clothesecommerce/features/favourites/presentaion/cubit/fav_state.dart';
import 'package:clothesecommerce/features/product/data/models/product_model.dart';
import 'package:clothesecommerce/features/product/presentaion/cubit/product_cubit.dart';
import 'package:clothesecommerce/features/product/presentaion/cubit/product_state.dart';
import 'package:clothesecommerce/features/product/presentaion/pages/product_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final int productId;
  final int categoryId;
  final String categoryName;

  const ProductDetailPage({
    super.key,
    required this.categoryName,
    required this.productId,
    required this.categoryId,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  Widget build(BuildContext context) {
    context.read<FavoriteCubit>().loadFavorites();
    final cubit = context.read<ProductCubit>();
    cubit.fetchProductById(widget.productId);

    return FutureBuilder<bool>(
      future: AuthHelper.isAdmin(),
      builder: (ctx, snap) {
        final isAdmin = snap.data ?? false;

        return WillPopScope(
          onWillPop: () async {
            await cubit.fetchProductsByCategory(widget.categoryId);

            Navigator.pop(context);
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            body: BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: context.watch<AppColors>().primaryColor,
                    ),
                  );
                } else if (state is ProductLoadedOne) {
                  final p = state.product;
                  return CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 350,
                        pinned: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Hero(
                            tag: "product_${p.productID}",
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                p.imageUrl.isEmpty
                                    ? Container(
                                        color: Colors.grey.shade300,
                                        child: const Icon(
                                          Icons.image,
                                          size: 64,
                                        ),
                                      )
                                    : Image.network(
                                        p.imageUrl,
                                        fit: BoxFit.cover,
                                      ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.2),
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.2),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(30),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${p.price.toStringAsFixed(2)} ل.س",
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'المخزون المتبقي: ${widget.product.stockQuantity}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: widget.product.stockQuantity > 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                const Divider(height: 30),
                                Text(
                                  p.description.isEmpty
                                      ? "لا يوجد وصف"
                                      : p.description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // 🔥 زر المفضلة
                                BlocBuilder<FavoriteCubit, FavoriteState>(
                                  builder: (context, favState) {
                                    bool isFavorite = false;

                                    if (favState is FavoriteLoaded) {
                                      isFavorite = favState.favorites.any(
                                        (f) => f.productID == p.productID,
                                      );
                                    }

                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isFavorite
                                              ? Colors.red
                                              : Colors.blue,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        icon: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          isFavorite
                                              ? "إزالة من المفضلة"
                                              : "إضافة إلى المفضلة",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (isFavorite) {
                                            context
                                                .read<FavoriteCubit>()
                                                .removeFavorite(p.productID);
                                            context
                                                .read<FavoriteCubit>()
                                                .loadFavorites(); // تحديث القائمة
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "تمت إزالة المنتج من المفضلة",
                                                ),
                                              ),
                                            );
                                          } else {
                                            context
                                                .read<FavoriteCubit>()
                                                .addFavorite(p.productID);
                                            context
                                                .read<FavoriteCubit>()
                                                .loadFavorites(); // تحديث القائمة
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "تمت إضافة المنتج إلى المفضلة",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                // 🔥 زر السلة
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          elevation: 8,
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            155,
                                            126,
                                            234,
                                          ),
                                        ),
                                        onPressed:
                                            widget.product.stockQuantity > 0
                                            ? () {
                                                final cartItem = CartItem(
                                                  product: widget.product,
                                                  quantity: 1,
                                                );
                                                setState(() {
                                                  widget
                                                          .product
                                                          .stockQuantity -=
                                                      1;
                                                });
                                                context
                                                    .read<CartCubit>()
                                                    .addProduct(cartItem);
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'تمت إضافة المنتج إلى السلة',
                                                    ),
                                                  ),
                                                );
                                              }
                                            : null,
                                        icon: const Icon(
                                          Icons.add_shopping_cart,
                                          color: Colors.black,
                                        ),
                                        label: const Text(
                                          "أضف للسلة",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (isAdmin) ...[
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            backgroundColor:
                                                const Color.fromARGB(
                                                  255,
                                                  235,
                                                  197,
                                                  148,
                                                ),
                                            elevation: 8,
                                          ),
                                          onPressed: () async {
                                            final updated =
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        BlocProvider.value(
                                                          value: cubit,
                                                          child:
                                                              ProductEditPage(
                                                                product: p,
                                                              ),
                                                        ),
                                                  ),
                                                );
                                            if (updated == true) {
                                              cubit.fetchProductById(
                                                widget.productId,
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.black,
                                          ),
                                          label: const Text(
                                            "تعديل",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            backgroundColor:
                                                const Color.fromARGB(
                                                  255,
                                                  238,
                                                  109,
                                                  109,
                                                ),
                                            elevation: 8,
                                          ),
                                          onPressed: () async {
                                            final ok = await showDialog<bool>(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text(
                                                  "تأكيد الحذف",
                                                ),
                                                content: Text(
                                                  'هل تريد حذف "${p.name}"؟',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text("إلغاء"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text(
                                                      "حذف",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (ok == true) {
                                              await cubit.deleteProduct(
                                                p.productID,
                                                categoryId: widget.categoryId,
                                              );
                                              await cubit
                                                  .fetchProductsByCategory(
                                                    widget.categoryId,
                                                  );
                                              Navigator.pop(context);
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.black,
                                          ),
                                          label: const Text(
                                            "حذف",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (state is ProductError) {
                  return Center(
                    child: Text(
                      "خطأ: ${state.message}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        );
      },
    );
  }
}
