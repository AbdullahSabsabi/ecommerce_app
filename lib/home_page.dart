import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/core/models/user_model.dart';
import 'package:clothesecommerce/core/network/is_admin.dart';
import 'package:clothesecommerce/features/cart/presentaion/cubit/cart_cubit.dart';
import 'package:clothesecommerce/features/cart/presentaion/pages/cart_pages.dart';
import 'package:clothesecommerce/features/category/data/api/category_api.dart';
import 'package:clothesecommerce/features/category/presentaion/cubit/category_cubit.dart';
import 'package:clothesecommerce/features/category/presentaion/pages/category_page.dart';
import 'package:clothesecommerce/features/favourites/presentaion/pages/fav_pages.dart';
import 'package:clothesecommerce/features/order/presentaion/pages/orders_pages.dart';
import 'package:clothesecommerce/features/product/presentaion/pages/all_products_page.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryPage extends StatefulWidget {
  static String nameScreen = 'CategoryPage';
  final Dio dio;

  const CategoryPage({super.key, required this.dio});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  int _currentIndex = 2; // المنتجات بالوسط
  bool _isAdmin = false;
  User _user = User.empty();
  bool _initialized = false;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final isAdmin = await AuthHelper.isAdmin();
    final user = await AuthHelper.getUserFromToken();

    setState(() {
      _user = user!;
      _isAdmin = isAdmin;
      _pages = [
        FavoritesPage(dio: widget.dio),
        BlocProvider(
          create: (_) =>
              CategoryCubit(CategoryApi(widget.dio))..fetchCategories(),
          child: ScaffoldCategoryWidget(isAdmin: _isAdmin),
        ),
        AllProductsPage(dio: widget.dio, categoryId: 0, categoryName: ''),
        MyOrdersPage(currentUser: _user),
        BlocProvider(create: (_) => CartCubit(), child: CartPage()),
      ];
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.watch<AppColors>().primaryColor;

    if (!_initialized) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.white,
        activeColor: primaryColor,
        color: Colors.grey[600],
        style: TabStyle.reactCircle, // حركة جميلة عند التحديد
        items: const [
          TabItem(icon: Icons.favorite, title: 'المفضلة'),
          TabItem(icon: Icons.category, title: 'الفئات'),
          TabItem(icon: Icons.shopping_bag, title: 'المنتجات'),
          TabItem(icon: Icons.receipt_long, title: 'الطلبات'),
          TabItem(icon: Icons.shopping_cart, title: 'سلة المشتريات'),
        ],
        initialActiveIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
