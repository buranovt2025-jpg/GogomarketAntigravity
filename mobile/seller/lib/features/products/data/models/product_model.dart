class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final String? categoryId;
  final int stockQuantity;
  final bool isActive;
  final String sellerId;
  final int ordersCount;
  final double rating;
  final int reviewsCount;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    this.categoryId,
    required this.stockQuantity,
    required this.isActive,
    required this.sellerId,
    this.ordersCount = 0,
    this.rating = 0.0,
    this.reviewsCount = 0,
    required this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      categoryId: json['categoryId'],
      stockQuantity: json['stockQuantity'] ?? 0,
      isActive: json['isActive'] ?? false,
      sellerId: json['sellerId'],
      ordersCount: json['ordersCount'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewsCount: json['reviewsCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'images': images,
      'categoryId': categoryId,
      'stockQuantity': stockQuantity,
      'isActive': isActive,
      'sellerId': sellerId,
      'ordersCount': ordersCount,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
