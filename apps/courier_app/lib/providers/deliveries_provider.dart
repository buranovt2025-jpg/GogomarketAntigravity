import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'api_client_provider.dart';

// Модель заказа для курьера (упрощенная)
class CourierOrder {
  final String id;
  final String title;
  final String address;
  final String status;
  final double price;

  CourierOrder({
    required this.id,
    required this.title,
    required this.address,
    required this.status,
    required this.price,
  });

  factory CourierOrder.fromJson(Map<String, dynamic> json) {
    return CourierOrder(
      id: json['id']?.toString() ?? '',
      title: 'Заказ #${json['id']}',
      address: json['deliveryAddress']?.toString() ?? 'Нет адреса',
      status: json['status']?.toString() ?? 'PAID',
      price: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DeliveriesState {
  final List<CourierOrder> availableOrders;
  final List<CourierOrder> myDeliveries;
  final bool isLoading;
  final String? error;

  const DeliveriesState({
    this.availableOrders = const [],
    this.myDeliveries = const [],
    this.isLoading = false,
    this.error,
  });

  DeliveriesState copyWith({
    List<CourierOrder>? availableOrders,
    List<CourierOrder>? myDeliveries,
    bool? isLoading,
    String? error,
  }) {
    return DeliveriesState(
      availableOrders: availableOrders ?? this.availableOrders,
      myDeliveries: myDeliveries ?? this.myDeliveries,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DeliveriesNotifier extends StateNotifier<DeliveriesState> {
  final Ref _ref;

  DeliveriesNotifier(this._ref) : super(const DeliveriesState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    try {
      final api = _ref.read(apiClientProvider);
      
      // Заказы, готовые к доставке (оплаченные)
      final availableRaw = await api.getOrders(status: 'PAID');
      
      // Мои активные доставки
      final myRaw = await api.getOrders(status: 'DELIVERING');
      
      state = state.copyWith(
        availableOrders: (availableRaw as List).map((e) => CourierOrder.fromJson(e)).toList(),
        myDeliveries: (myRaw as List).map((e) => CourierOrder.fromJson(e)).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> acceptOrder(String orderId) async {
    try {
      final api = _ref.read(apiClientProvider);
      await api.updateOrderStatus(orderId, 'DELIVERING');
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Не удалось взять заказ: $e');
      return false;
    }
  }

  Future<bool> completeOrder(String orderId) async {
    try {
      final api = _ref.read(apiClientProvider);
      await api.updateOrderStatus(orderId, 'COMPLETED');
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Не удалось завершить заказ: $e');
      return false;
    }
  }
}

final deliveriesProvider = StateNotifierProvider<DeliveriesNotifier, DeliveriesState>((ref) => DeliveriesNotifier(ref));
