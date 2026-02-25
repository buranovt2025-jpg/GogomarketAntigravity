import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

// === Cart Item ===
class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);
}

// === Cart State ===
class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  double get total => items.fold(0, (s, e) => s + e.subtotal);
  int get itemCount => items.fold(0, (s, e) => s + e.quantity);
  bool get isEmpty => items.isEmpty;

  CartState copyWith({List<CartItem>? items}) =>
      CartState(items: items ?? this.items);
}

// === Cart Notifier ===
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addProduct(Product product) {
    final items = [...state.items];
    final idx = items.indexWhere((e) => e.product.id == product.id);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
    } else {
      items.add(CartItem(product: product, quantity: 1));
    }
    state = state.copyWith(items: items);
  }

  void removeProduct(String productId) {
    state = state.copyWith(
      items: state.items.where((e) => e.product.id != productId).toList(),
    );
  }

  void incrementQuantity(String productId) {
    final items = state.items.map((e) {
      if (e.product.id == productId) {
        return e.copyWith(quantity: e.quantity + 1);
      }
      return e;
    }).toList();
    state = state.copyWith(items: items);
  }

  void decrementQuantity(String productId) {
    final items = state.items
        .map((e) {
          if (e.product.id == productId) {
            return e.copyWith(quantity: e.quantity - 1);
          }
          return e;
        })
        .where((e) => e.quantity > 0)
        .toList();
    state = state.copyWith(items: items);
  }

  void clear() {
    state = const CartState();
  }
}

// === Provider ===
final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);

// Shortcut — количество товаров (для бейджа на иконке)
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).itemCount;
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).total;
});
