class Product {
  final String id;
  final String name;
  final String? specifications;
  final double purchasePrice;
  final double salePrice;
  final int stockQuantity;

  Product({
    required this.id,
    required this.name,
    this.specifications,
    required this.purchasePrice,
    required this.salePrice,
    required this.stockQuantity,
  });

  double get profitMargin => salePrice - purchasePrice;
  bool get isLowStock => stockQuantity < 5;

  Product copyWith({
    String? id,
    String? name,
    String? specifications,
    double? purchasePrice,
    double? salePrice,
    int? stockQuantity,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      specifications: specifications ?? this.specifications,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specifications': specifications,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'stock_quantity': stockQuantity,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      specifications: map['specifications'],
      purchasePrice: (map['purchase_price'] ?? 0).toDouble(),
      salePrice: (map['sale_price'] ?? 0).toDouble(),
      stockQuantity: map['stock_quantity']?.toInt() ?? 0,
    );
  }
}
