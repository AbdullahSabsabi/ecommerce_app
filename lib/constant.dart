import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors extends ChangeNotifier {
  Color _primaryColor = const Color.fromARGB(
    255,
    4,
    110,
    136,
  ); // اللون الافتراضي
  Color get primaryColor => _primaryColor;

  final List<Color> availableColors = [
    Color.fromARGB(255, 4, 110, 136),
    const Color(0xFF3498DB), // أزرق ساطع
    const Color(0xFFE74C3C), // أحمر حيوي
    const Color(0xFF9B59B6), // بنفسجي جميل
    const Color(0xFF2ECC71), // أخضر مشرق
    const Color(0xFF34495E), // رمادي داكن أنيق
    const Color(0xFFe67e22), // برتقالي دافئ
    const Color(0xFF16a085), // أخضر أزرق هادئ
    const Color(0xFF2980B9),
    Colors.teal, // أزرق ملكي
  ];

  AppColors() {
    _loadColor();
  }

  Future<void> _loadColor() async {
    final prefs = await SharedPreferences.getInstance();
    int? colorValue = prefs.getInt('primaryColor');
    if (colorValue != null) {
      _primaryColor = Color(colorValue);
      notifyListeners();
    }
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', color.value);
  }
}
