import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/core/network/dio_client.dart';
import 'package:clothesecommerce/features/category/data/models/category_model.dart';
import 'package:clothesecommerce/features/category/presentaion/cubit/category_cubit.dart';
import 'package:clothesecommerce/features/category/presentaion/pages/category_add_page.dart';
import 'package:clothesecommerce/features/favourites/presentaion/cubit/fav_cubit.dart';
import 'package:clothesecommerce/features/product/presentaion/pages/products_page.dart';
import 'package:clothesecommerce/features/category/presentaion/pages/category_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//##############################################################################
class CustomCard extends StatelessWidget {
  CustomCard({super.key, required this.category, required this.isAdmin});

  final Category category;
  final bool isAdmin;
  final dio = DioClient.create();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductListByCategoryPage(
              dio: dio, // مرّر الـ Dio من صفحة الفئات
              categoryId: category.categoryId,
              categoryName: category.name,
            ),
          ),
        );
        await context.read<FavoriteCubit>().loadFavorites();
      },

      child: Container(
        padding: const EdgeInsets.only(top: 20, left: 14, right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 250, 250, 250).withOpacity(1),
              context.watch<AppColors>().primaryColor.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: context.watch<AppColors>().primaryColor.withOpacity(0.1),
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(4, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.watch<AppColors>().primaryColor.withOpacity(1),
              ),
              child: Center(
                child: Icon(
                  Icons.category_outlined,
                  size: 54,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.watch<AppColors>().primaryColor,
                fontSize: 25,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  category.description ?? '',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // أزرار التعديل والحذف للـ Admin مع تأثير ripple وألوان متناسقة
            if (isAdmin)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomEditButton(category: category),
                  const SizedBox(width: 30),
                  CustomDeleteButton(category: category),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

//##############################################################################

class CustomDeleteButton extends StatelessWidget {
  const CustomDeleteButton({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 26),
      splashRadius: 22,
      tooltip: "حذف الفئة",
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: Text('هل تريد حذف الفئة "${category.name}"؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('حذف'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          context.read<CategoryCubit>().deleteCategory(category.categoryId);
        }
      },
    );
  }
}
//##############################################################################

class CustomEditButton extends StatelessWidget {
  const CustomEditButton({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit, color: Colors.white, size: 26),
      splashRadius: 22,
      tooltip: "تعديل الفئة",
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<CategoryCubit>(),
              child: CategoryEditScreen(category: category),
            ),
          ),
        );
      },
    );
  }
}
//##############################################################################

class NoCategoriesWidget extends StatelessWidget {
  const NoCategoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 100,
            color: context.watch<AppColors>().primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 25),
          Text(
            'لا توجد فئات حالياً',
            style: TextStyle(
              fontSize: 22,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  color: context.watch<AppColors>().primaryColor.withOpacity(
                    0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'اضغط زر الإضافة لإنشاء فئة جديدة',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
//##############################################################################

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: context.watch<AppColors>().primaryColor,
      child: const Icon(Icons.add, color: Colors.white, size: 25),
      onPressed: () {
        Navigator.pushNamed(context, CategoryAddPage.nameScreen);
      },
      elevation: 8,
      tooltip: 'إضافة فئة جديدة',
    );
  }
}
