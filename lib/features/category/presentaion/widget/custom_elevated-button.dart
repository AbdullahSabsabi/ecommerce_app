import 'package:clothesecommerce/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomElevatedButton extends StatelessWidget {
  CustomElevatedButton({
    super.key,
    required this.title,
    required this.onpressed,
  });
  String title;
  Function() onpressed;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 250,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: context.watch<AppColors>().primaryColor,
        ),
        onPressed: onpressed,

        child: Text(title, style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
