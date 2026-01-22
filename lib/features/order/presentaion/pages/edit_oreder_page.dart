import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/features/order/data/models/order_model.dart';
import 'package:clothesecommerce/features/order/presentaion/cubit/order_cubit.dart';
import 'package:clothesecommerce/features/order/presentaion/cubit/order_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class EditOrderPage extends StatefulWidget {
  final int orderId;

  const EditOrderPage({super.key, required this.orderId});

  @override
  State<EditOrderPage> createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  int? selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().getOrderById(widget.orderId);
  }

  void _saveChanges(Order order) async {
    final updatedOrder = order.copyWith(
      orderStatus: selectedStatus,
      updateAt: DateTime.now(),
    );

    try {
      await context.read<OrderCubit>().updateOrder(updatedOrder);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ تم تحديث حالة الطلب بنجاح"),
          backgroundColor: Colors.green,
        ),
      );

      await context.read<OrderCubit>().getAllOrders();
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ فشل تحديث الطلب: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.watch<AppColors>().primaryColor;

    return WillPopScope(
      onWillPop: () async {
        await context.read<OrderCubit>().getAllOrders();
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            ' تعديل حالة الطلب',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: primaryColor,
          centerTitle: true,
          elevation: 6,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<OrderCubit, OrderState>(
            builder: (context, state) {
              if (state is OrderLoadedSingle) {
                final order = state.order;
                selectedStatus ??= order.orderStatus;

                return ListView(
                  children: [
                    // ===== بطاقة تفاصيل الطلب =====
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              Icons.receipt_long,
                              "رقم الطلب",
                              "#${order.id}",
                            ),
                            const Divider(),
                            _buildInfoRow(
                              Icons.attach_money,
                              "المبلغ الإجمالي",
                              "${order.totalAmount.toStringAsFixed(2)} ل.س",
                            ),
                            const Divider(),
                            _buildInfoRow(
                              Icons.date_range,
                              "تاريخ الإنشاء",
                              DateFormat(
                                'dd-MM-yyyy HH:mm',
                              ).format(order.createdAt),
                            ),
                            const Divider(),
                            _buildInfoRow(
                              Icons.update,
                              "آخر تحديث",
                              DateFormat(
                                'dd-MM-yyyy HH:mm',
                              ).format(order.updateAt),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // ===== اختيار حالة الطلب =====
                    Text(
                      "📌 حالة الطلب",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text("قيد المعالجة")),
                        DropdownMenuItem(value: 1, child: Text("قيد التوصيل")),
                        DropdownMenuItem(value: 2, child: Text("مكتمل")),
                      ],
                      onChanged: (val) => setState(() => selectedStatus = val),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ===== زر الحفظ =====
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                      ),
                      onPressed: () => _saveChanges(order),
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        "حفظ التعديلات",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                );
              } else if (state is OrderLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: context.watch<AppColors>().primaryColor,
                  ),
                );
              } else if (state is OrderError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                );
              } else {
                return const Center(child: Text("فشل تحميل الطلب"));
              }
            },
          ),
        ),
      ),
    );
  }

  // 🔹 عنصر معلومات قابل لإعادة الاستخدام
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 10),
        Text(
          "$label:",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
