import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cart_item.dart';
import '../../products/data/models/product_model.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct(ProductModel product, {int quantity = 1}) {
    final existingIndex = state.indexWhere((item) => item.productId == product.id);

    if (existingIndex != -1) {
      final updatedCart = [...state];
      updatedCart[existingIndex].quantity += quantity;
      state = updatedCart;
    } else {
      state = [
        ...state,
        CartItem(
          productId: product.id,
          productName: product.name,
          price: product.price,
          images: product.images,
          quantity: quantity,
        ),
      ];
    }
  }

  void removeProduct(String productId) {
    state = state.where((item) => item.productId != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }

    state = [
      for (final item in state)
        if (item.productId == productId)
          CartItem(
            productId: item.productId,
            productName: item.productName,
            price: item.price,
            images: item.images,
            quantity: quantity,
          )
        else
          item,
    ];
  }

  void clear() {
    state = [];
  }

  double get total {
    return state.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  int get itemCount {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider.notifier).total;
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider.notifier).itemCount;
});
