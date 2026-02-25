class StoryModel {
  final String id;
  final String sellerId;
  final SellerInfo seller;
  final String? productId;
  final ProductInfo? product;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? description;
  final int viewsCount;
  final int likesCount;
  final int sharesCount;
  final int duration;
  final bool isLiked;
  final DateTime createdAt;

  StoryModel({
    required this.id,
    required this.sellerId,
    required this.seller,
    this.productId,
    this.product,
    required this.videoUrl,
    this.thumbnailUrl,
    this.description,
    required this.viewsCount,
    required this.likesCount,
    required this.sharesCount,
    required this.duration,
    this.isLiked = false,
    required this.createdAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'],
      sellerId: json['sellerId'],
      seller: SellerInfo.fromJson(json['seller'] ?? {}),
      productId: json['productId'],
      product: json['product'] != null ? ProductInfo.fromJson(json['product']) : null,
      videoUrl: json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      description: json['description'],
      viewsCount: json['viewsCount'] ?? 0,
      likesCount: json['likesCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      duration: json['duration'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  StoryModel copyWith({bool? isLiked, int? likesCount}) {
    return StoryModel(
      id: id,
      sellerId: sellerId,
      seller: seller,
      productId: productId,
      product: product,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      description: description,
      viewsCount: viewsCount,
      likesCount: likesCount ?? this.likesCount,
      sharesCount: sharesCount,
      duration: duration,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
    );
  }
}

class SellerInfo {
  final String id;
  final String phone;
  final String? businessName;

  SellerInfo({
    required this.id,
    required this.phone,
    this.businessName,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      businessName: json['sellerProfile']?['businessName'],
    );
  }
}

class ProductInfo {
  final String id;
  final String name;
  final double price;
  final List<String> images;

  ProductInfo({
    required this.id,
    required this.name,
    required this.price,
    required this.images,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['id'],
      name: json['name'],
      price: (json['price'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
    );
  }
}
