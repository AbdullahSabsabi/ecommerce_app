import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/core/network/dio_client.dart';
import 'package:clothesecommerce/features/cart/presentaion/cubit/cart_cubit.dart';
import 'package:clothesecommerce/features/category/data/api/category_api.dart';
import 'package:clothesecommerce/features/category/presentaion/pages/category_add_page.dart';
import 'package:clothesecommerce/features/favourites/data/api/fav_api.dart';
import 'package:clothesecommerce/features/favourites/presentaion/cubit/fav_cubit.dart';
import 'package:clothesecommerce/features/login/presentation/pages/login_pages.dart';
import 'package:clothesecommerce/features/order/data/api/order_api.dart';
import 'package:clothesecommerce/features/order/presentaion/cubit/order_cubit.dart';
import 'package:clothesecommerce/features/product/data/api/product_api.dart';
import 'package:clothesecommerce/features/product/presentaion/cubit/product_cubit.dart';
import 'package:clothesecommerce/features/register/presentation/pages/register_page.dart';
import 'package:clothesecommerce/features/reports/data/api/report_api.dart';
import 'package:clothesecommerce/features/reports/presentaion/cubit/report_cubit.dart';
import 'package:clothesecommerce/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'package:dio/dio.dart';

void main() {
  final dio = DioClient.create();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppColors()), // 🔥 AppColors
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider(create: (_) => CategoryApi(dio)),
            RepositoryProvider(create: (_) => ProductCubit(ProductApi(dio))),
            BlocProvider(create: (context) => CartCubit()),
            BlocProvider(create: (context) => ReportCubit(ReportApi(dio))),
            BlocProvider(create: (_) => OrderCubit(OrdersApi(dio))),
            BlocProvider(create: (_) => FavoriteCubit(FavoriteApi(dio))),
          ],
          child: MyApp(dio: dio),
        ),
      ],
      child: MyApp(dio: dio),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Dio dio;
  const MyApp({super.key, required this.dio});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppColors>(
      builder: (context, appColors, _) {
        return MaterialApp(
          routes: {
            RegisterPage.nameScreen: (context) => RegisterPage(dio: dio),
            LoginPage.nameScreen: (context) => LoginPage(dio: dio),
            CategoryPage.nameScreen: (context) => CategoryPage(dio: dio),
            CategoryAddPage.nameScreen: (context) => CategoryAddPage(),
          },
          theme: ThemeData(
            fontFamily: 'Cairo',
            primaryColor: context.watch<AppColors>().primaryColor,
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.blue,
            ).copyWith(secondary: context.watch<AppColors>().primaryColor),
            scaffoldBackgroundColor: Colors.grey[100],
            appBarTheme: AppBarTheme(
              backgroundColor: context.watch<AppColors>().primaryColor,
              foregroundColor: Colors.white,
              elevation: 6,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.watch<AppColors>().primaryColor,
              ),
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: SplashScreen(dio: dio),
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },
        );
      },
    );
  }
}
