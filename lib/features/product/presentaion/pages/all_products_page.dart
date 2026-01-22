import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/core/network/is_admin.dart';
import 'package:clothesecommerce/features/favourites/data/api/fav_api.dart';
import 'package:clothesecommerce/features/favourites/presentaion/cubit/fav_cubit.dart';
import 'package:clothesecommerce/features/product/data/api/product_api.dart';
import 'package:clothesecommerce/features/product/data/models/product_model.dart';
import 'package:clothesecommerce/features/product/presentaion/cubit/product_cubit.dart';
import 'package:clothesecommerce/features/product/presentaion/cubit/product_state.dart';
import 'package:clothesecommerce/features/product/presentaion/pages/detailes_all_page.dart';
import 'package:clothesecommerce/features/product/presentaion/pages/product_edit_page.dart';
import 'package:clothesecommerce/features/product/presentaion/widget/custom_card.dart';
import 'package:clothesecommerce/features/reports/presentaion/pages/reports_pages.dart';
import 'package:clothesecommerce/profile_pages.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllProductsPage extends StatefulWidget {
  static String nameScreen = 'AllProductsPage';
  final Dio dio;
  final int categoryId;
  final String categoryName;

  const AllProductsPage({
    super.key,
    required this.dio,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  String searchQuery = '';
  String sortOption = 'latest'; // latest | price_low_high | price_high_low

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

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  FavoriteCubit(FavoriteApi(widget.dio))..loadFavorites(),
            ),
            BlocProvider(
              create: (_) =>
                  ProductCubit(ProductApi(widget.dio))..fetchProducts(),
            ),
          ],
          child: Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            drawer: ProfilePage(),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              backgroundColor: context.watch<AppColors>().primaryColor,
              centerTitle: true,
              title: const Text(
                'جميع المنتجات',
                style: TextStyle(color: Colors.white),
              ),
              foregroundColor: Colors.white,
            ),

            // زر اختيار الترتيب
            floatingActionButton: FloatingActionButton(
              backgroundColor: context.watch<AppColors>().primaryColor,
              onPressed: _openSortOptions,
              child: const Icon(Icons.sort, color: Colors.white),
            ),

            body: Column(
              children: [
                // مربع البحث تحت الـ AppBar
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => searchQuery = value.toLowerCase()),
                  ),
                ),

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
                        // 1) فلترة حسب البحث
                        final List<Product> filteredProducts = state.products
                            .where(
                              (p) => p.name.toLowerCase().contains(searchQuery),
                            )
                            .toList();

                        // 2) تطبيق الترتيب المختار
                        switch (sortOption) {
                          case 'price_low_high':
                            filteredProducts.sort(
                              (a, b) => a.price.compareTo(b.price),
                            );
                            break;
                          case 'price_high_low':
                            filteredProducts.sort(
                              (a, b) => b.price.compareTo(a.price),
                            );
                            break;
                          case 'latest':
                          default:
                            // إذا عندك createdAt استخدمه، وإلا productID كبديل منطقي للأحدث
                            filteredProducts.sort(
                              (a, b) => b.productID.compareTo(a.productID),
                            );
                            break;
                        }

                        if (filteredProducts.isEmpty) {
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
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: .70,
                              ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, i) {
                            final p = filteredProducts[i];
                            return ProductCard(
                              product: p,
                              isAdmin: false,
                              onOpen: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<ProductCubit>(),
                                      child: AllProductDetailPage(
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
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('تأكيد الحذف'),
                                    content: Text('هل تريد حذف "${p.name}"؟'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('إلغاء'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text(
                                          'حذف',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  await context
                                      .read<ProductCubit>()
                                      .deleteProduct(
                                        p.productID,
                                        categoryId: p.categoryID,
                                      );
                                  context.read<ProductCubit>().fetchProducts();
                                }
                              },
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<ProductCubit>(),
                                      child: ProductEditPage(product: p),
                                    ),
                                  ),
                                );
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
