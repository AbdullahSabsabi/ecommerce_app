import 'package:clothesecommerce/features/product/data/models/product_model.dart';

class OrderItem {
  final int orderItem_ID;
  final int product_ID;
  final Product product;
  final double unitPrice;
  final int quantity;
  final double discountValue;
  final double totalPrice;

  OrderItem({
    required this.orderItem_ID,
    required this.product_ID,
    required this.product,
    required this.unitPrice,
    required this.quantity,
    required this.discountValue,
    required this.totalPrice,
  });

  factory OrderItem.empty() => OrderItem(
    orderItem_ID: 0,
    product_ID: 0,
    product: Product.empty(),
    unitPrice: 0,
    quantity: 0,
    discountValue: 0,
    totalPrice: 0,
  );

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    orderItem_ID: json['orderItem_ID'] ?? 0,
    product_ID: json['product_ID'] ?? 0,
    product: json['product'] != null
        ? Product.fromJson(json['product'])
        : Product.empty(),
    unitPrice: (json['unitPrice'] ?? 0).toDouble(),
    quantity: json['quantity'] ?? 0,
    discountValue: (json['discountValue'] ?? 0).toDouble(),
    totalPrice: (json['totalPrice'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'orderItem_ID': orderItem_ID,
    'product_ID': product_ID,
    'product': product.toJson(),
    'unitPrice': unitPrice,
    'quantity': quantity,
    'discountValue': discountValue,
    'totalPrice': totalPrice,
  };

  OrderItem copyWith({
    int? orderItem_ID,
    int? product_ID,
    Product? product,
    double? unitPrice,
    int? quantity,
    double? discountValue,
    double? totalPrice,
  }) {
    return OrderItem(
      orderItem_ID: orderItem_ID ?? this.orderItem_ID,
      product_ID: product_ID ?? this.product_ID,
      product: product ?? this.product,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      discountValue: discountValue ?? this.discountValue,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
