class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final String? categoryId;
  final int stockQuantity;
  final String sellerId;
  final double rating;
  final int reviewsCount;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    this.categoryId,
    required this.stockQuantity,
    required this.sellerId,
    this.rating = 0.0,
    this.reviewsCount = 0,
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
      sellerId: json['sellerId'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewsCount: json['reviewsCount'] ?? 0,
    );
  }
}
