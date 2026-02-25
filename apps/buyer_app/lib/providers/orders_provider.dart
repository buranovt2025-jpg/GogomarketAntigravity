import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client_provider.dart';
import 'cart_provider.dart';
import 'auth_provider.dart';

// ===================== STATE =====================

class OrdersState {
  final bool isPlacingOrder;
  final String? lastOrderId;
  final String? error;
  final List<dynamic> orders;

  const OrdersState({
    this.isPlacingOrder = false,
    this.lastOrderId,
    this.error,
    this.orders = const [],
  });

  OrdersState copyWith({
    bool? isPlacingOrder,
    String? lastOrderId,
    String? error,
    List<dynamic>? orders,
    bool clearError = false,
  }) =>
      OrdersState(
        isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
        lastOrderId: lastOrderId ?? this.lastOrderId,
        error: clearError ? null : error ?? this.error,
        orders: orders ?? this.orders,
      );
}

// ===================== NOTIFIER =====================

class OrdersNotifier extends StateNotifier<OrdersState> {
  final Ref _ref;

  OrdersNotifier(this._ref) : super(const OrdersState());

  Future<bool> placeOrder({String deliveryAddress = 'Адрес доставки'}) async {
    final cart = _ref.read(cartProvider);
    if (cart.isEmpty) return false;

    final isAuth = _ref.read(isAuthenticatedProvider);
    if (!isAuth) {
      state = state.copyWith(error: 'Необходима авторизация');
      return false;
    }

    state = state.copyWith(isPlacingOrder: true, clearError: true);
    try {
      final api = _ref.read(apiClientProvider);
      final items = cart.items
          .map((item) => {
                'productId': item.product.id,
                'quantity': item.quantity,
                'price': item.product.price,
              })
          .toList();

      final data = await api.createOrder(
        items: items,
        deliveryAddress: deliveryAddress,
      );

      //清空 корзину после успешного заказа
      _ref.read(cartProvider.notifier).clear();
      state = state.copyWith(
        isPlacingOrder: false,
        lastOrderId: data['id']?.toString(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isPlacingOrder: false,
        error: 'Ошибка при оформлении: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> loadOrders() async {
    try {
      final api = _ref.read(apiClientProvider);
      final data = await api.getOrders();
      state = state.copyWith(orders: data);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// ===================== PROVIDERS =====================

final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>(
  (ref) => OrdersNotifier(ref),
);
