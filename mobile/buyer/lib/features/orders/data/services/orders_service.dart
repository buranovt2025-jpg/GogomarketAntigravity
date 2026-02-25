import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_client.dart';
import '../../../cart/data/models/cart_item.dart';

final ordersServiceProvider = Provider<OrdersService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OrdersService(apiClient);
});

class OrdersService {
  final ApiClient _apiClient;

  OrdersService(this._apiClient);

  Future<Map<String, dynamic>> createOrder({
    required List<CartItem> items,
    required Map<String, dynamic> deliveryAddress,
  }) async {
    final orderItems = items.map((item) => {
      'productId': item.productId,
      'quantity': item.quantity,
      'price': item.price,
    }).toList();

    final response = await _apiClient.post(
      '/orders',
      data: {
        'items': orderItems,
        'deliveryAddress': deliveryAddress,
      },
    );

    return response.data;
  }

  Future<List<dynamic>> getMyOrders() async {
    final response = await _apiClient.get('/orders');
    return response.data as List<dynamic>;
  }
}
