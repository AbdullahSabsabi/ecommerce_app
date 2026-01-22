import 'package:clothesecommerce/features/order/presentaion/pages/mtn_page.dart';
import 'package:clothesecommerce/features/order/presentaion/pages/syriatel_page.dart';
import 'package:clothesecommerce/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseCompanyPage extends StatelessWidget {
  final VoidCallback onPaymentSuccess;

  const ChooseCompanyPage({super.key, required this.onPaymentSuccess});

  Widget _buildPaymentButton({
    required Color iconColor,
    required Color textColor,
    required String label,
    required Color startColor,
    required Color endColor,
    required String logoPath,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: startColor.withOpacity(0.4),
                offset: const Offset(0, 8),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // شعار الشركة
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  logoPath,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "اختر الشركة",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 6,
        backgroundColor: context.watch<AppColors>().primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // زر MTN
            _buildPaymentButton(
              iconColor: Colors.black,
              textColor: Colors.black,
              label: "MTN Cash",
              startColor: Colors.amber.shade400,
              endColor: Colors.amberAccent,
              logoPath: 'assets/images/MTN.jpg', // ضع شعار MTN هنا
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MTNPaymentPage(onPaymentSuccess: onPaymentSuccess),
                  ),
                );
              },
            ),
            const SizedBox(height: 25),

            // زر Syriatel
            _buildPaymentButton(
              iconColor: Colors.white,
              textColor: Colors.white,
              label: "Syriatel Cash",
              startColor: Colors.redAccent,
              endColor: Colors.red.shade900,
              logoPath: 'assets/images/Syriatel.jpg', // ضع شعار Syriatel هنا
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SyriatelPaymentPage(onPaymentSuccess: onPaymentSuccess),
                  ),
                );
              },
            ),

            const SizedBox(height: 50),

            // نص إضافي وجمالية
            Column(
              children: [
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.watch<AppColors>().primaryColor.withOpacity(
                          0.3,
                        ),
                        context.watch<AppColors>().primaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.payment, size: 60, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "اختر طريقة الدفع المفضلة لديك",
                  style: TextStyle(fontSize: 25, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "آمنة وسريعة وسهلة الاستخدام",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
