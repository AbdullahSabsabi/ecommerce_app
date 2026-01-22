import 'package:clothesecommerce/core/models/user_model.dart';

import 'order_item_model.dart';

class Order {
  final int id;
  final int user_ID;
  final User user;
  final int orderStatus;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updateAt;
  final int paymentMethod;
  final DateTime paymentDate;
  final List<OrderItem> orderItems;

  Order({
    required this.id,
    required this.user_ID,
    required this.user,
    required this.orderStatus,
    required this.totalAmount,
    required this.createdAt,
    required this.updateAt,
    required this.paymentMethod,
    required this.paymentDate,
    required this.orderItems,
  });

  factory Order.empty() => Order(
    id: 0,
    user_ID: 0,
    user: User.empty(),
    orderStatus: 0,
    totalAmount: 0,
    createdAt: DateTime.now(),
    updateAt: DateTime.now(),
    paymentMethod: 0,
    paymentDate: DateTime.now(),
    orderItems: [],
  );

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] ?? 0,
    user_ID: json['user_ID'] ?? 0,
    user: json['user'] != null ? User.fromJson(json['user']) : User.empty(),
    orderStatus: json['orderStatus'] ?? 0,
    totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    updateAt: json['updateAt'] != null
        ? DateTime.parse(json['updateAt'])
        : DateTime.now(),
    paymentMethod: json['paymentMethod'] ?? 0,
    paymentDate: json['paymentDate'] != null
        ? DateTime.parse(json['paymentDate'])
        : DateTime.now(),
    orderItems: json['orderItems'] != null
        ? List<OrderItem>.from(
            json['orderItems'].map((item) => OrderItem.fromJson(item)),
          )
        : [],
  );

  Map<String, dynamic> toJson() => {
    'id': id, // لاحظ اسم الحقل كما في API
    'userId': user_ID,
    'orderStatus': orderStatus,
    'totalAmount': totalAmount,
    'createdAt': createdAt.toIso8601String(),
    'updateAt': updateAt.toIso8601String(),
    'paymentMethod': paymentMethod,
    'paymentDate': paymentDate.toIso8601String(),
    'orderItems': orderItems.map((e) => e.toJson()).toList(),
  };

  Order copyWith({
    int? id,
    int? user_ID,
    User? user,
    int? orderStatus,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updateAt,
    int? paymentMethod,
    DateTime? paymentDate,
    List<OrderItem>? orderItems,
  }) {
    return Order(
      id: id ?? this.id,
      user_ID: user_ID ?? this.user_ID,
      user: user ?? this.user,
      orderStatus: orderStatus ?? this.orderStatus,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updateAt: updateAt ?? this.updateAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      orderItems: orderItems ?? this.orderItems,
    );
  }
}
