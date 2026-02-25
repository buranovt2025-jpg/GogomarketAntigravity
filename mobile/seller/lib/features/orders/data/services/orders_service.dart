import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/order_model.dart';

final ordersServiceProvider = Provider<OrdersService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OrdersService(apiClient);
});

class OrdersService {
  final ApiClient _apiClient;

  OrdersService(this._apiClient);

  Future<List<OrderModel>> getMyOrders({String? status}) async {
    final queryParams = status != null ? {'status': status} : null;
    final response = await _apiClient.get(
      ApiEndpoints.products.replaceAll('products', 'orders'),
      queryParameters: queryParams,
    );
    
    final List<dynamic> data = response.data;
    return data.map((json) => OrderModel.fromJson(json)).toList();
  }

  Future<OrderModel> getOrderById(String orderId) async {
    final response = await _apiClient.get(
      '/orders/$orderId',
    );
    return OrderModel.fromJson(response.data);
  }

  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final response = await _apiClient.put(
      '/orders/$orderId/status',
      data: {'status': status},
    );
    return OrderModel.fromJson(response.data);
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await _apiClient.get('/orders/stats');
    return response.data;
  }
}
