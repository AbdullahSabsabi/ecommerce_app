import 'package:flutter/material.dart';

class MTNPaymentPage extends StatefulWidget {
  final VoidCallback onPaymentSuccess;
  const MTNPaymentPage({super.key, required this.onPaymentSuccess});

  @override
  State<MTNPaymentPage> createState() => _MTNPaymentPageState();
}

class _MTNPaymentPageState extends State<MTNPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    emailController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _submitPayment() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم الدفع بنجاح عبر MTN Cash"),
          backgroundColor: Colors.green,
        ),
      );

      widget.onPaymentSuccess();
    }
  }

  Color color = Colors.yellow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        foregroundColor: Colors.black,
        title: const Text(
          "MTN - معلومات الدفع",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.amber.shade400,
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        //padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image(
                width: double.infinity,
                height: 200,
                fit: BoxFit.fill,
                image: AssetImage('assets/images/MTN.jpg'),
              ),
              SizedBox(height: 50),
              // الاسم الكامل
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "الاسم الكامل",
                    prefixIcon: const Icon(Icons.person, color: Colors.amber),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    filled: true,
                    fillColor: color.withOpacity(0.1),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "الرجاء إدخال الاسم الكامل";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 15),

              // رقم الهاتف
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  controller: numberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "رقم الهاتف",
                    prefixIcon: const Icon(Icons.phone, color: Colors.amber),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    filled: true,
                    fillColor: color.withOpacity(0.1),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "الرجاء إدخال رقم الهاتف";
                    }
                    final phoneReg = RegExp(r'^\d{6,15}$');
                    if (!phoneReg.hasMatch(value)) {
                      return "رقم الهاتف غير صالح";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 15),

              // البريد الإلكتروني (اختياري)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "البريد الإلكتروني (اختياري)",
                    prefixIcon: const Icon(Icons.email, color: Colors.amber),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    filled: true,
                    fillColor: color.withOpacity(0.1),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final emailReg = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailReg.hasMatch(value)) {
                        return "البريد الإلكتروني غير صالح";
                      }
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "رقم الحساب",
                    prefixIcon: const Icon(
                      Icons.account_balance,
                      color: Colors.amber,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    filled: true,
                    fillColor: Colors.amber.withOpacity(0.1),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "الرجاء إدخال رقم الحساب";
                    }
                    if (double.tryParse(value) == null) {
                      return "المبلغ غير صالح";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 50),

              // زر الدفع Gradient
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: InkWell(
                    onTap: _submitPayment,
                    borderRadius: BorderRadius.circular(20),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.amber.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          "تأكيد الدفع",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
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
