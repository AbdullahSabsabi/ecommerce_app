import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/features/cart/data/models/cart_model.dart';
import 'package:clothesecommerce/features/cart/presentaion/cubit/cart_cubit.dart';
import 'package:clothesecommerce/features/favourites/presentaion/cubit/fav_cubit.dart';
import 'package:clothesecommerce/features/favourites/presentaion/cubit/fav_state.dart';
import 'package:clothesecommerce/features/product/data/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final bool isAdmin;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ProductCard({
    required this.product,
    required this.isAdmin,
    required this.onOpen,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  // متغير محلي لتتبع حالة المفضلة
  bool isLocalFavorite = false;

  @override
  void initState() {
    super.initState();
    // تهيئة المتغير بحسب Cubit عند بناء الكارد
    final state = context.read<FavoriteCubit>().state;
    if (state is FavoriteLoaded) {
      isLocalFavorite = state.favorites.any(
        (fav) => fav.productID == widget.product.productID,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onOpen,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              context.watch<AppColors>().primaryColor.withOpacity(.85),
              context.watch<AppColors>().primaryColor.withOpacity(.55),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.10),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // داخل _ProductCard
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    (widget.product.imageUrl.isEmpty ||
                        widget.product.imageUrl.toLowerCase() == "null")
                    ? Container(
                        color: Colors.white24,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image,
                          size: 48,
                          color: Colors.white70,
                        ),
                      )
                    : Image.network(
                        widget.product.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        // ✅ إضافة مؤشر تحميل
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: context.watch<AppColors>().primaryColor,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        // ✅ إذا فيه خطأ في التحميل
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: Colors.white24,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Colors.white70,
                            ),
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              widget.product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${widget.product.price.toStringAsFixed(2)} ل.س",
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // أزرار التحكم
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // زر المفضلة
                Expanded(
                  child: BlocBuilder<FavoriteCubit, FavoriteState>(
                    builder: (context, state) {
                      bool isFavorite = false;

                      if (state is FavoriteLoaded) {
                        // تحقق إذا المنتج موجود في قائمة المفضلة
                        isFavorite = state.favorites.any(
                          (p) => p.productID == widget.product.productID,
                        );
                      }

                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          if (isFavorite) {
                            context.read<FavoriteCubit>().removeFavorite(
                              widget.product.productID,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تمت إزالة المنتج من المفضلة'),
                              ),
                            );
                          } else {
                            context.read<FavoriteCubit>().addFavorite(
                              widget.product.productID,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تمت إضافة المنتج إلى المفضلة'),
                              ),
                            );
                          }
                        },
                        tooltip: 'المفضلة',
                      );
                    },
                  ),
                ),

                // زر إضافة للسلة للجميع
                Expanded(
                  child: IconButton(
                    icon: const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      final cartItem = CartItem(
                        product: widget.product, // المنتج اللي موجود في الصفحة
                        quantity: 1, // نبدأ بالكمية 1
                      );
                      setState(() {
                        widget.product.stockQuantity -= 1;
                      });

                      // إضافة المنتج للسلة
                      context.read<CartCubit>().addProduct(cartItem);
                      // TODO: اربطه مع CartCubit إذا موجود
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تمت إضافة المنتج إلى السلة'),
                        ),
                      );
                    },
                    tooltip: 'أضِف إلى السلة',
                  ),
                ),

                if (widget.isAdmin) ...[
                  const SizedBox(width: 4),
                  Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: widget.onEdit,
                      tooltip: 'تعديل',
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: widget.onDelete,
                      tooltip: 'حذف',
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
