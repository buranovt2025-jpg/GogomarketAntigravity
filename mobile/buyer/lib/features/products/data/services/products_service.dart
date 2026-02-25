import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_client.dart';
import '../models/product_model.dart';

final productsServiceProvider = Provider<ProductsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductsService(apiClient);
});

class ProductsService {
  final ApiClient _apiClient;

  ProductsService(this._apiClient);

  Future<List<ProductModel>> getProducts({
    String? search,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null) queryParams['search'] = search;
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;

    final response = await _apiClient.get(
      '/products',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final List<dynamic> data = response.data;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<ProductModel> getProductById(String productId) async {
    final response = await _apiClient.get('/products/$productId');
    return ProductModel.fromJson(response.data);
  }
}
