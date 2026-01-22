import 'package:clothesecommerce/features/product/data/models/product_model.dart';

class User {
  final int id;
  final String userName;
  final String email;
  final String phoneNumber;
  final String fullName;
  final int role; // 0 = User, 1 = Admin
  final List<Product> favorites;

  User({
    required this.id,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.fullName,
    required this.role,
    required this.favorites,
  });

  /// مستخدم افتراضي
  factory User.empty() => User(
    id: 0,
    userName: '',
    email: '',
    phoneNumber: '',
    fullName: '',
    role: 0,
    favorites: [],
  );

  /// إنشاء من JSON
  factory User.fromJson(Map<String, dynamic> json) {
    var favList = <Product>[];
    if (json['favorites'] != null && json['favorites'] is List) {
      favList = List<Product>.from(
        (json['favorites'] as List).map((item) => Product.fromJson(item)),
      );
    }
    return User(
      id: json['id'] ?? 0,
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 0,
      favorites: favList,
    );
  }

  /// تحويل لكائن JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'userName': userName,
    'email': email,
    'phoneNumber': phoneNumber,
    'fullName': fullName,
    'role': role,
    'favorites': favorites.map((e) => e.toJson()).toList(),
  };
}
