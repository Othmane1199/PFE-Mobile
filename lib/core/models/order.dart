class Order {
  final String id;
  final String clientId;
  final double totalAmount;
  final String status; // 'En attente', 'Payé', 'Annulé'
  final DateTime? createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.clientId,
    required this.totalAmount,
    this.status = 'Payé',
    this.createdAt,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'client_id': clientId,
      'total_amount': totalAmount,
      'status': status,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, List<OrderItem> items) {
    return Order(
      id: map['id']?.toString() ?? '',
      clientId: map['client_id']?.toString() ?? '',
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      status: map['status'] ?? 'Payé',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      items: items,
    );
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id']?.toString() ?? '',
      orderId: map['order_id']?.toString() ?? '',
      productId: map['product_id']?.toString() ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unit_price'] ?? 0).toDouble(),
    );
  }
}
