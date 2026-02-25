import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/products_service.dart';
import '../data/models/product_model.dart';

final myProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final productsService = ref.watch(productsServiceProvider);
  return productsService.getMyProducts();
});

class ProductsNotifier extends StateNotifier<AsyncValue<List<ProductModel>>> {
  final ProductsService _productsService;

  ProductsNotifier(this._productsService) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = const AsyncValue.loading();
    try {
      final products = await _productsService.getMyProducts();
      state = AsyncValue.data(products);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> createProduct({
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    String? categoryId,
    List<String>? images,
  }) async {
    try {
      await _productsService.createProduct(
        name: name,
        description: description,
        price: price,
        stockQuantity: stockQuantity,
        categoryId: categoryId,
        images: images,
      );
      await loadProducts();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _productsService.deleteProduct(productId);
      await loadProducts();
    } catch (error) {
      rethrow;
    }
  }
}

final productsNotifierProvider =
    StateNotifierProvider<ProductsNotifier, AsyncValue<List<ProductModel>>>((ref) {
  final productsService = ref.watch(productsServiceProvider);
  return ProductsNotifier(productsService);
});
