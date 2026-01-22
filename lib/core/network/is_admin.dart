import 'dart:convert';
import 'package:clothesecommerce/core/models/user_model.dart';
import 'package:clothesecommerce/features/cart/presentaion/cubit/cart_cubit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthHelper {
  static final _storage = FlutterSecureStorage();

  /// استرجاع التوكن
  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt');
  }

  static Future<bool> isAdmin() async {
    final token = await _storage.read(key: 'jwt');
    if (token == null) return false;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> payloadMap = json.decode(decoded);

      // حسب JWT عندك المفتاح الصحيح للـ role
      final role =
          payloadMap['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
          '';

      return role.toString().toLowerCase() == 'admin';
    } catch (e) {
      return false;
    }
  }

  /// مسح التوكن (مثلاً عند تسجيل خروج)
  static Future<void> logout() async {
    await _storage.delete(key: 'jwt');
    await CartCubit().clearCart();
  }

  /// استخراج معلومات المستخدم من التوكن
  static Future<User?> getUserFromToken() async {
    final token = await _storage.read(key: 'jwt');
    if (token == null) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> payloadMap = json.decode(decoded);

      return User(
        id:
            int.tryParse(
              payloadMap["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"]
                  .toString(),
            ) ??
            0,
        userName:
            payloadMap["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"] ??
            "",
        email:
            payloadMap["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"] ??
            "",
        phoneNumber: "", // لا يوجد بالـ JWT
        fullName: "", // لا يوجد بالـ JWT
        role:
            payloadMap["http://schemas.microsoft.com/ws/2008/06/identity/claims/role"]
                    .toString()
                    .toLowerCase() ==
                "admin"
            ? 1
            : 0,
        favorites: [], // لا يوجد بالـ JWT
      );
    } catch (e) {
      print("Error decoding token: $e");
      return null;
    }
  }
}
