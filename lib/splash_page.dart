import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/features/register/presentation/pages/register_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({super.key, required this.dio});
  Dio dio;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconAnimation;

  late AnimationController _textController;
  late Animation<double> _textPulse;

  @override
  void initState() {
    super.initState();

    // Icon scale & fade animation
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _iconAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    _iconController.forward();

    // Text pulse animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _textPulse = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );
    _textController.repeat(reverse: true);

    // Navigate to Home after 3 seconds
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => RegisterPage(dio: widget.dio)),
      );
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.watch<AppColors>().primaryColor.withOpacity(0.3),
              context.watch<AppColors>().primaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _iconAnimation,
                child: const Icon(
                  Icons.shopping_bag,
                  color: Colors.white,
                  size: 100,
                ),
              ),
              const SizedBox(height: 20),
              ScaleTransition(
                scale: _textPulse,
                child: Text(
                  'WASK STYLE',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
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
