import 'package:clothesecommerce/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomField extends StatelessWidget {
  CustomField({
    super.key,
    required this.onsaved,
    required this.label,
    this.init,
  });

  Function(String?)? onsaved;
  String label;
  String? init;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: TextFormField(
        onSaved: onsaved,
        initialValue: init,
        decoration: InputDecoration(
          filled: true,
          fillColor: context.watch<AppColors>().primaryColor.withOpacity(0.1),
          labelText: label,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: context.watch<AppColors>().primaryColor,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black),
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "الحقل مطلوب" : null,
      ),
    );
  }
}
