import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/core/network/is_admin.dart';
import 'package:clothesecommerce/features/favourites/presentaion/cubit/fav_cubit.dart';
import 'package:clothesecommerce/features/product/data/api/product_api.dart';
import 'package:clothesecommerce/features/product/presentaion/cubit/product_cubit.dart';
import 'package:clothesecommerce/features/product/presentaion/cubit/product_state.dart';
import 'package:clothesecommerce/features/product/presentaion/pages/add_product_page.dart';
import 'package:clothesecommerce/features/product/presentaion/pages/product_detailes_page.dart';
import 'package:clothesecommerce/features/product/presentaion/pages/product_edit_page.dart';
import 'package:clothesecommerce/features/product/presentaion/widget/custom_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductListByCategoryPage extends StatefulWidget {
  static String nameScreen = 'ProductListByCategoryPage';
  final Dio dio;
  final int categoryId;
  final String categoryName;

  const ProductListByCategoryPage({
    super.key,
    required this.dio,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ProductListByCategoryPage> createState() =>
      _ProductListByCategoryPageState();
}

class _ProductListByCategoryPageState extends State<ProductListByCategoryPage> {
  String searchQuery = '';
  String sortOption = 'latest'; // latest | price_low_high | price_high_low

  Future<void> _refreshProducts() async {
    await context.read<ProductCubit>().fetchProductsByCategory(
      widget.categoryId,
    );
  }

  void _openSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ترتيب حسب',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('الأحدث'),
              onTap: () {
                setState(() => sortOption = 'latest');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: const Text('السعر: من الأقل سعر للأعلى سعر'),
              onTap: () {
                setState(() => sortOption = 'price_low_high');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: const Text('السعر: من الأعلى سعر للأقل سعر'),
              onTap: () {
                setState(() => sortOption = 'price_high_low');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthHelper.isAdmin(),
      builder: (ctx, snap) {
        final isAdmin = snap.data ?? false;

        return BlocProvider(
          create: (_) =>
              ProductCubit(ProductApi(widget.dio))
                ..fetchProductsByCategory(widget.categoryId),
          child: Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            appBar: AppBar(
              backgroundColor: context.watch<AppColors>().primaryColor,
              centerTitle: true,
              title: Text(
                'منتجات : ${widget.categoryName}',
                style: const TextStyle(color: Colors.white),
              ),
              foregroundColor: Colors.white,
            ),

            // ✅ زر الإضافة إذا كان أدمن
            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: "sort",
                  backgroundColor: context.watch<AppColors>().primaryColor,
                  onPressed: _openSortOptions,
                  child: const Icon(Icons.sort, color: Colors.white),
                ),
                const SizedBox(height: 12),
                if (isAdmin)
                  FloatingActionButton(
                    heroTag: "add",
                    backgroundColor: context.watch<AppColors>().primaryColor,
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<ProductCubit>(),
                            child: ProductAddPage(
                              categoryId: widget.categoryId,
                              categoryName: widget.categoryName,
                            ),
                          ),
                        ),
                      );
                      _refreshProducts();
                    },
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
              ],
            ),

            body: Column(
              children: [
                // 🔎 مربع البحث
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'ابحث عن منتج...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: context.watch<AppColors>().primaryColor,
                      ),
                      filled: true,
                      fillColor: context
                          .watch<AppColors>()
                          .primaryColor
                          .withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => searchQuery = value.toLowerCase()),
                  ),
                ),

                // 🛒 المنتجات
                Expanded(
                  child: BlocBuilder<ProductCubit, ProductState>(
                    builder: (context, state) {
                      if (state is ProductLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: context.watch<AppColors>().primaryColor,
                          ),
                        );
                      } else if (state is ProductLoaded) {
                        // فلترة
                        final filtered = state.products
                            .where(
                              (p) => p.name.toLowerCase().contains(searchQuery),
                            )
                            .toList();

                        // تطبيق الترتيب
                        switch (sortOption) {
                          case 'price_low_high':
                            filtered.sort((a, b) => a.price.compareTo(b.price));
                            break;
                          case 'price_high_low':
                            filtered.sort((a, b) => b.price.compareTo(a.price));
                            break;
                          case 'latest':
                          default:
                            filtered.sort(
                              (a, b) => b.productID.compareTo(a.productID),
                            );
                            break;
                        }

                        if (filtered.isEmpty) {
                          // حالة لا يوجد منتجات
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 80,
                                  color: context
                                      .watch<AppColors>()
                                      .primaryColor
                                      .withOpacity(0.5),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'لا يوجد أي منتجات حالياً',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'جرّب لاحقاً أو تحقق من أقسام أخرى',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: .70,
                              ),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final p = filtered[i];
                            return ProductCard(
                              product: p,
                              isAdmin: false,
                              onOpen: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<ProductCubit>(),
                                      child: ProductDetailPage(
                                        product: p,
                                        productId: p.productID,
                                        categoryId: widget.categoryId,
                                        categoryName: widget.categoryName,
                                      ),
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  setState(() {
                                    context
                                        .read<FavoriteCubit>()
                                        .loadFavorites();
                                    context
                                        .read<ProductCubit>()
                                        .fetchProductsByCategory(
                                          widget.categoryId,
                                        );
                                  });
                                }
                              },
                              onDelete: () async {
                                /*...*/
                              },
                              onEdit: () {
                                /*...*/
                              },
                            );
                          },
                        );
                      } else if (state is ProductError) {
                        return Center(
                          child: Text(
                            'خطأ: ${state.message}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
