import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/core/network/is_admin.dart';
import 'package:clothesecommerce/features/order/data/models/order_model.dart';
import 'package:clothesecommerce/features/order/presentaion/pages/edit_oreder_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clothesecommerce/features/order/presentaion/cubit/order_cubit.dart';
import 'package:intl/intl.dart';

class OrderDetailsPageAll extends StatefulWidget {
  final Order order;

  OrderDetailsPageAll({super.key, required this.order});

  @override
  State<OrderDetailsPageAll> createState() => _OrderDetailsPageAllState();
}

class _OrderDetailsPageAllState extends State<OrderDetailsPageAll> {
  final isAdmin = AuthHelper.isAdmin();

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

  String paymentMethodText(int method) {
    switch (method) {
      case 0:
        return 'الدفع عند الاستلام';
      case 1:
        return 'بطاقة ائتمان';
      default:
        return 'غير معروف';
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<OrderCubit>().deleteOrder(widget.order.id);
              await context.read<OrderCubit>().getAllOrders();
              Navigator.pop(ctx); // إغلاق الديالوج
              Navigator.pop(context); // رجوع لصفحة طلباتي
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await context.read<OrderCubit>().getAllOrders();
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: const Text(
            'تفاصيل الطلب',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: context.watch<AppColors>().primaryColor,
          centerTitle: true,
          elevation: 6,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات الطلب
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      context.watch<AppColors>().primaryColor.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: const Offset(0, 6),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طلب #${widget.order.id}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      'طريقة الدفع: ${paymentMethodText(widget.order.paymentMethod)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'المبلغ الإجمالي: ${widget.order.totalAmount.toStringAsFixed(2)} ل.س',
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 4),
                    Text(
                      'تاريخ الإنشاء: ${DateFormat('dd-MM-yyyy HH:mm').format(widget.order.createdAt)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'تاريخ التحديث: ${DateFormat('dd-MM-yyyy HH:mm').format(widget.order.updateAt)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'المنتجات:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // قائمة المنتجات
              Expanded(
                child: ListView.builder(
                  itemCount: widget.order.orderItems.length,
                  itemBuilder: (context, index) {
                    final item = widget.order.orderItems[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            context.watch<AppColors>().primaryColor.withOpacity(
                              0.05,
                            ),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: item.product.imageUrl.isNotEmpty
                              ? Image.network(
                                  item.product.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        title: Text(
                          item.product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'الكمية: ${item.quantity}\n'
                          'السعر للوحدة: ${item.unitPrice} ل.س\n'
                          'الإجمالي: ${item.totalPrice} ل.س',
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              // أزرار التعديل والحذف أسفل الصفحة
              // أزرار التعديل والحذف أسفل الصفحة
              FutureBuilder<bool>(
                future: AuthHelper.isAdmin(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Text("حصل خطأ بالتأكد من الصلاحيات");
                  }

                  final isAdmin = snapshot.data ?? false;

                  return Row(
                    children: [
                      if (true) // ✅ يظهر فقط إذا المستخدم أدمن
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditOrderPage(orderId: widget.order.id),
                                ),
                              );
                              setState(() async {
                                await context.read<OrderCubit>().getOrderById(
                                  widget.order.id,
                                );
                              });
                            },
                            icon: const Icon(Icons.edit, color: Colors.black),
                            label: const Text(
                              'تعديل',
                              style: TextStyle(color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (true)
                        const SizedBox(width: 16), // مسافة بس إذا في تعديل
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showDeleteDialog(context),
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text(
                            'حذف',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
