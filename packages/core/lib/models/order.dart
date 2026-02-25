import 'package:freezed_annotation/freezed_annotation.dart';
import 'product.dart';

part 'order.freezed.dart';
part 'order.g.dart';

enum OrderStatus { pending, confirmed, packed, delivering, delivered, cancelled }

@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required Product product,
    required int quantity,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}

@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required String buyerId,
    required List<OrderItem> items,
    required double total,
    required OrderStatus status,
    required DateTime createdAt,
    String? courierId,
    String? deliveryAddress,
    String? note,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
