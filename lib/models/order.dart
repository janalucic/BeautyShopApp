class OrderItem {
  final int productId;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}

class UserOrder {
  final int id;
  final int userId;
  final String status;
  final double totalPrice;
  final List<OrderItem> items;

  UserOrder({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalPrice,
    required this.items,
  });

  factory UserOrder.fromJson(Map<String, dynamic> json) {
    return UserOrder(
      id: json['id'],
      userId: json['userId'],
      status: json['status'],
      totalPrice: (json['totalPrice'] as num).toDouble(),
      items: (json['items'] as List)
          .map((item) =>
          OrderItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'status': status,
      'totalPrice': totalPrice,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
