class Favorite {
  final int productId;
  Favorite({required this.productId});

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(productId: json['product_ID']);
  }

  Map<String, dynamic> toJson() {
    return {'product_ID': productId};
  }
}
