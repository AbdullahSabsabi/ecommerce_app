import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/core/network/is_admin.dart';
import 'package:clothesecommerce/features/cart/presentaion/cubit/cart_cubit.dart';
import 'package:clothesecommerce/features/cart/presentaion/cubit/cart_state.dart';
import 'package:clothesecommerce/features/order/presentaion/pages/create_order_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    // تحميل السلة من SharedPreferences عند بداية الصفحة
    context.read<CartCubit>().loadCart();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'سلة المشتريات',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: context.watch<AppColors>().primaryColor,
        elevation: 0,
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 100,
                      color: context
                          .watch<AppColors>()
                          .primaryColor
                          .withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'السلة فارغة',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: item.product.imageUrl.isNotEmpty
                                    ? Image.network(
                                        item.product.imageUrl,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                width: 100,
                                                height: 100,
                                                color: Colors.white24,
                                                alignment: Alignment.center,
                                                child: const Icon(
                                                  Icons.image,
                                                  size: 48,
                                                  color: Colors.white70,
                                                ),
                                              );
                                            },
                                      )
                                    : Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.white24,
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.image,
                                          size: 48,
                                          color: Colors.white70,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${(item.quantity * item.product.price).toStringAsFixed(2)}  ل.س',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            int newQuantity = item.quantity - 1;
                                            if (newQuantity > 0) {
                                              context
                                                  .read<CartCubit>()
                                                  .updateQuantity(
                                                    item.product.productID,
                                                    newQuantity,
                                                  );
                                            } else {
                                              context
                                                  .read<CartCubit>()
                                                  .removeProduct(
                                                    item.product.productID,
                                                  );
                                            }
                                            setState(() {
                                              item.product.stockQuantity += 1;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: Colors.redAccent,
                                            size: 28,
                                          ),
                                        ),
                                        Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            context
                                                .read<CartCubit>()
                                                .updateQuantity(
                                                  item.product.productID,
                                                  item.quantity + 1,
                                                );

                                            setState(() {
                                              item.product.stockQuantity -= 1;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                            color: Colors.green,
                                            size: 28,
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          onPressed: () {
                                            context
                                                .read<CartCubit>()
                                                .removeProduct(
                                                  item.product.productID,
                                                );
                                          },
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                            size: 28,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: const Offset(0, -2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'المجموع الكلي:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${state.totalPrice.toStringAsFixed(2)} ل.س',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: context.watch<AppColors>().primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            final user = await AuthHelper.getUserFromToken();
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('يرجى تسجيل الدخول أولاً'),
                                ),
                              );
                              return;
                            }

                            final cartState = context.read<CartCubit>().state;
                            if (cartState is! CartLoaded ||
                                cartState.items.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('السلة فارغة')),
                              );
                              return;
                            }

                            final cartItems = cartState.items;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateOrderPage(
                                  cartItems: cartItems,
                                  user: user,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context
                                .watch<AppColors>()
                                .primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'الدفع والطلب',

                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return Center(
            child: CircularProgressIndicator(
              color: context.watch<AppColors>().primaryColor,
            ),
          );
        },
      ),
    );
  }
}
