import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/features/category/presentaion/cubit/category_cubit.dart';
import 'package:clothesecommerce/features/category/presentaion/cubit/category_state.dart';
import 'package:clothesecommerce/features/category/presentaion/widget/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScaffoldCategoryWidget extends StatefulWidget {
  const ScaffoldCategoryWidget({super.key, required this.isAdmin});
  final bool isAdmin;

  @override
  State<ScaffoldCategoryWidget> createState() => _ScaffoldCategoryWidgetState();
}

class _ScaffoldCategoryWidgetState extends State<ScaffoldCategoryWidget> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: context.watch<AppColors>().primaryColor,
        centerTitle: true,
        elevation: 6,
        title: const Text(
          'الفئات',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      floatingActionButton: widget.isAdmin
          ? CustomFloatingActionButton()
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // مربع البحث
            TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن فئة...',
                prefixIcon: Icon(
                  Icons.search,
                  color: context.watch<AppColors>().primaryColor,
                ),
                filled: true,
                fillColor: context.watch<AppColors>().primaryColor.withOpacity(
                  0.1,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim();
                });
              },
            ),

            const SizedBox(height: 16),

            // القائمة
            Expanded(
              child: BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: context.watch<AppColors>().primaryColor,
                      ),
                    );
                  } else if (state is CategoryLoaded) {
                    // فلترة حسب البحث
                    final filteredCategories = state.categories.where((
                      category,
                    ) {
                      return category.name.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      );
                    }).toList();

                    if (filteredCategories.isEmpty) {
                      // حالة لا توجد فئات
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 80,
                              color: context
                                  .watch<AppColors>()
                                  .primaryColor
                                  .withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "لا توجد فئات",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.2,
                          ),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        return CustomCard(
                          category: category,
                          isAdmin: widget.isAdmin,
                        );
                      },
                    );
                  } else if (state is CategoryError) {
                    return Center(
                      child: Text(
                        'حدث خطأ: ${state.message}',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
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
  }
}
