class Product {
  final int productID;
  final String name;
  String imageUrl;
  int stockQuantity;
  final double price;
  final String description;
  final int categoryID;
  final Category? category;

  Product({
    required this.productID,
    required this.name,
    required this.imageUrl,
    required this.stockQuantity,
    required this.price,
    required this.description,
    required this.categoryID,
    this.category,
  });

  factory Product.empty() => Product(
    productID: 0,
    name: '',
    imageUrl: '',
    price: 0.0,
    stockQuantity: 0,
    description: '',
    categoryID: 0,
  );

  factory Product.fromJson(Map<String, dynamic> json) {
    // معالجة الصورة
    String img = '';
    if (json['imageUrl'] != null &&
        (json['imageUrl'] is String) &&
        (json['imageUrl'] as String).toLowerCase() != 'null') {
      img = json['imageUrl'] as String;
    }

    // معالجة السعر
    double parsedPrice = 0.0;
    var p = json['price'];
    if (p != null) {
      if (p is int) {
        parsedPrice = p.toDouble();
      } else if (p is double) {
        parsedPrice = p;
      } else if (p is String) {
        parsedPrice = double.tryParse(p) ?? 0.0;
      }
    }

    return Product(
      productID: json['product_ID'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: img,
      stockQuantity: json['stockQuantity'] ?? 0,
      price: parsedPrice,
      description: json['description'] ?? '',
      categoryID: json['category_ID'] ?? 0,
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_ID': productID,
      'name': name,
      'imageUrl': imageUrl,
      'stockQuantity': stockQuantity,
      'price': price, // بيضل double
      'description': description,
      'category_ID': categoryID,
      'category': category?.toJson(),
    };
  }

  Product copyWith({
    int? productID,
    String? name,
    String? imageUrl,
    int? stockQuantity,
    double? price,
    String? description,
    int? categoryID,
    Category? category,
  }) {
    return Product(
      productID: productID ?? this.productID,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      price: price ?? this.price,
      description: description ?? this.description,
      categoryID: categoryID ?? this.categoryID,
      category: category ?? this.category,
    );
  }
}

class Category {
  final int categoryID;
  final String name;

  Category({required this.categoryID, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryID: json['category_ID'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'category_ID': categoryID, 'name': name};
  }
}
