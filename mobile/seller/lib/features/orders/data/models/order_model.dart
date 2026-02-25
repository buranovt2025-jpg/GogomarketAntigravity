class OrderModel {
  final String id;
  final String orderNumber;
  final String buyerId;
  final String sellerId;
  final String status;
  final String paymentStatus;
  final double total;
  final List<OrderItemModel> items;
  final DeliveryAddress deliveryAddress;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.buyerId,
    required this.sellerId,
    required this.status,
    required this.paymentStatus,
    required this.total,
    required this.items,
    required this.deliveryAddress,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      orderNumber: json['orderNumber'],
      buyerId: json['buyerId'],
      sellerId: json['sellerId'],
      status: json['status'],
      paymentStatus: json['paymentStatus'],
      total: (json['total'] ?? 0).toDouble(),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromJson(item))
              .toList() ??
          [],
      deliveryAddress: DeliveryAddress.fromJson(json['deliveryAddress']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class OrderItemModel {
  final String id;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;

  OrderItemModel({
    required this.id,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      productName: json['productName'],
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }
}

class DeliveryAddress {
  final String name;
  final String phone;
  final String address;
  final String city;

  DeliveryAddress({
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
    );
  }
}
