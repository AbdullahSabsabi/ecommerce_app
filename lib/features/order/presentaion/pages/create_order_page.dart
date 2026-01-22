import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/core/models/user_model.dart';
import 'package:clothesecommerce/features/cart/data/models/cart_model.dart';
import 'package:clothesecommerce/features/cart/presentaion/cubit/cart_cubit.dart';
import 'package:clothesecommerce/features/login/presentation/pages/login_pages.dart';
import 'package:clothesecommerce/features/order/presentaion/cubit/order_cubit.dart';
import 'package:clothesecommerce/features/order/presentaion/pages/choose_company_page.dart';
import 'package:clothesecommerce/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateOrderPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final User user;

  const CreateOrderPage({
    super.key,
    required this.cartItems,
    required this.user,
  });

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  int _paymentMethod = 0; // 0 = كاش، 1 = بطاقة

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.user.phoneNumber;
  }

  double get totalAmount {
    return widget.cartItems.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  void _submitOrder() async {
    final orderRequest = {
      "userId": widget.user.id,
      "orderStatus": 0,
      "paymentMethod": _paymentMethod,
      "totalAmount": totalAmount,
      "paymentDate": DateTime.now().toIso8601String(),
      "createdAt": DateTime.now().toIso8601String(),
      "updatedAt": DateTime.now().toIso8601String(),
      "phone": _phoneController.text.trim(),
      "orderItems": widget.cartItems.map((cartItem) {
        return {
          "product_Id": cartItem.product.productID,
          "unitPrice": cartItem.product.price,
          "quantity": cartItem.quantity,
          "totalPrice": cartItem.product.price * cartItem.quantity,
        };
      }).toList(),
    };

    try {
      await context.read<OrderCubit>().createOrderFromJson(orderRequest);
      print(orderRequest);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إنشاء الطلب بنجاح')));

      await context.read<CartCubit>().clearCart();
      await context.read<OrderCubit>().getOrdersByUser(widget.user.id);

      Navigator.pushNamedAndRemoveUntil(
        context,
        CategoryPage.nameScreen,
        (route) => route.settings.name == LoginPage.nameScreen,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل إنشاء الطلب: $e')));
    }
  }

  void _confirmOrder() {
    if (_formKey.currentState!.validate()) {
      if (_paymentMethod == 0) {
        _submitOrder();
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChooseCompanyPage(
              onPaymentSuccess: () {
                _submitOrder();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.watch<AppColors>().primaryColor;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          "إنشاء طلب",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // رقم الهاتف
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "رقم الهاتف",
                  prefixIcon: Icon(
                    Icons.phone,
                    color: context.watch<AppColors>().primaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  filled: true,
                  fillColor: context
                      .watch<AppColors>()
                      .primaryColor
                      .withOpacity(0.1),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  final phoneReg = RegExp(r'^\d{6,15}$');
                  if (!phoneReg.hasMatch(value)) {
                    return 'رقم الهاتف غير صالح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // ملاحظات
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: "ملاحظات (اختياري)",
                  prefixIcon: Icon(
                    Icons.note,
                    color: context.watch<AppColors>().primaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  filled: true,
                  fillColor: context
                      .watch<AppColors>()
                      .primaryColor
                      .withOpacity(0.1),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // طريقة الدفع
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: DropdownButtonFormField<int>(
                    value: _paymentMethod,
                    decoration: const InputDecoration(border: InputBorder.none),
                    items: const [
                      DropdownMenuItem(
                        value: 0,
                        child: Row(
                          children: [
                            Icon(Icons.money, color: Colors.green),
                            SizedBox(width: 10),
                            Text("الدفع عند الاستلام"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(Icons.credit_card, color: Colors.blue),
                            SizedBox(width: 10),
                            Text("بطاقة مصرفية"),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() => _paymentMethod = val!);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ملخص الطلب
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: context
                        .watch<AppColors>()
                        .primaryColor
                        .withOpacity(0.1),
                    child: Icon(
                      Icons.shopping_cart,
                      color: context.watch<AppColors>().primaryColor,
                    ),
                  ),
                  title: Text(
                    "عدد المنتجات: ${widget.cartItems.length}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "المجموع الكلي: $totalAmount",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // زر التأكيد مع Gradient
              SizedBox(
                width: double.infinity,
                height: 60,
                child: InkWell(
                  onTap: _confirmOrder,
                  borderRadius: BorderRadius.circular(20),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor.withOpacity(0.8), primaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.4),
                          offset: const Offset(0, 6),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "تأكيد الطلب",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
