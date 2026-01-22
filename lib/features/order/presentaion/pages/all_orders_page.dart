import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/core/models/user_model.dart';
import 'package:clothesecommerce/core/network/is_admin.dart';
import 'package:clothesecommerce/features/order/presentaion/cubit/order_cubit.dart';
import 'package:clothesecommerce/features/order/presentaion/cubit/order_state.dart';
import 'package:clothesecommerce/features/order/presentaion/pages/detailes_order.dart';
import 'package:clothesecommerce/features/order/presentaion/pages/detailes_pages_all.dart';
import 'package:clothesecommerce/features/order/presentaion/pages/edit_oreder_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllOrdersPage extends StatefulWidget {
  User user;
  AllOrdersPage({super.key, required this.user});

  @override
  State<AllOrdersPage> createState() => _AllOrdersPageState();
}

class _AllOrdersPageState extends State<AllOrdersPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().getAllOrders(); // جلب جميع الطلبات
  }

  String orderStatusText(int status) {
    switch (status) {
      case 0:
        return 'قيد المعالجة';
      case 1:
        return 'قيد التوصيل';
      case 2:
        return 'مكتمل';
      default:
        return 'غير معروف';
    }
  }

  Color orderStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData orderStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.pending_actions;
      case 1:
        return Icons.local_shipping;
      case 2:
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthHelper.isAdmin(), // تحقق من الدور
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return WillPopScope(
            onWillPop: () async {
              await context.read<OrderCubit>().getOrdersByUser(widget.user.id);
              Navigator.pop(context);
              return true;
            },
            child: Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: context.watch<AppColors>().primaryColor,
                ),
              ),
            ),
          );
        }

        final bool isAdmin = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.grey.shade200,
          appBar: AppBar(
            foregroundColor: Colors.white,
            title: const Text(
              'جميع الطلبات',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: context.watch<AppColors>().primaryColor,
            elevation: 6,
          ),
          body: BlocBuilder<OrderCubit, OrderState>(
            builder: (context, state) {
              if (state is OrderLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: context.watch<AppColors>().primaryColor,
                  ),
                );
              } else if (state is OrderError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                );
              } else if (state is OrderLoaded) {
                if (state.orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 90,
                          color: context
                              .watch<AppColors>()
                              .primaryColor
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'لا توجد طلبات حالياً',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                            shadows: const [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 2,
                                color: Colors.black12,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'يمكنك تصفح المنتجات وإضافة طلب جديد',
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

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: state.orders.length,
                  itemBuilder: (context, index) {
                    final order = state.orders[index];
                    return GestureDetector(
                      onTap: () async {
                        // await Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (_) => OrderDetailsPageAll(order: order),
                        //   ),
                        // );
                        // setState(() {
                        //   context.read<OrderCubit>().getAllOrders();
                        // });
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditOrderPage(orderId: order.id),
                          ),
                        );
                        setState(() async {
                          await context.read<OrderCubit>().getOrderById(
                            order.id,
                          );
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context
                                  .watch<AppColors>()
                                  .primaryColor
                                  .withOpacity(0.2),
                              context
                                  .watch<AppColors>()
                                  .primaryColor
                                  .withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 6),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(20),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: orderStatusColor(
                              order.orderStatus,
                            ),
                            child: Icon(
                              orderStatusIcon(order.orderStatus),
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            'طلب #${order.id}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الحالة: ${orderStatusText(order.orderStatus)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'المبلغ: ${order.totalAmount.toStringAsFixed(2)} ل.س',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'المستخدم: ${order.user.userName}', // عرض اسم المستخدم
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: context.watch<AppColors>().primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
          floatingActionButton: false
              ? FloatingActionButton(
                  backgroundColor: context.watch<AppColors>().primaryColor,
                  onPressed: () {
                    // Admin action هنا
                  },
                  child: const Icon(Icons.receipt_long),
                )
              : null,
        );
      },
    );
  }
}
