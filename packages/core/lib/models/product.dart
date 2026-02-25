import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String title,
    required double price,
    required String sellerId,
    String? sellerName,
    required String category,
    @Default([]) List<String> imageUrls,
    String? description,
    @Default(0) int stock,
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    @Default(false) bool isFeatured,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
