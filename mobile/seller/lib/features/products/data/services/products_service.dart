import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/product_model.dart';

final productsServiceProvider = Provider<ProductsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductsService(apiClient);
});

class ProductsService {
  final ApiClient _apiClient;

  ProductsService(this._apiClient);

  Future<List<ProductModel>> getMyProducts() async {
    final response = await _apiClient.get(ApiEndpoints.myProducts);
    final List<dynamic> data = response.data;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<ProductModel> createProduct({
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    String? categoryId,
    List<String>? images,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.products,
      data: {
        'name': name,
        'description': description,
        'price': price,
        'stockQuantity': stockQuantity,
        if (categoryId != null) 'categoryId': categoryId,
        if (images != null) 'images': images,
      },
    );

    return ProductModel.fromJson(response.data);
  }

  Future<ProductModel> updateProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    int? stockQuantity,
    String? categoryId,
    List<String>? images,
    bool? isActive,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.productById(productId),
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (price != null) 'price': price,
        if (stockQuantity != null) 'stockQuantity': stockQuantity,
        if (categoryId != null) 'categoryId': categoryId,
        if (images != null) 'images': images,
        if (isActive != null) 'isActive': isActive,
      },
    );

    return ProductModel.fromJson(response.data);
  }

  Future<void> deleteProduct(String productId) async {
    await _apiClient.delete(ApiEndpoints.productById(productId));
  }

  Future<String> uploadImage(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });

    final response = await _apiClient.uploadFile(
      ApiEndpoints.uploadImage,
      formData,
    );

    return response.data['url'];
  }
}
