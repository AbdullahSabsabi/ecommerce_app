import 'package:flutter/material.dart';
import 'package:clothesecommerce/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomTextField extends StatefulWidget {
  CustomTextField({
    super.key,
    required this.icon,
    required this.controller,
    required this.label,
    this.ispass = false,
    this.type = TextInputType.text,
    required this.validate,
  });
  final String validate;
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool ispass;
  final TextInputType type;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.ispass;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
      child: TextFormField(
        keyboardType: widget.type,
        obscureText: _obscureText,
        controller: widget.controller,
        decoration: InputDecoration(
          labelStyle: const TextStyle(color: Colors.grey),
          labelText: widget.label,
          prefixIcon: Icon(
            widget.icon,
            color: context.watch<AppColors>().primaryColor,
          ),
          suffixIcon: widget.ispass
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: context.watch<AppColors>().primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
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
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) =>
            value == null || value.isEmpty ? widget.validate : null,
      ),
    );
  }
}
