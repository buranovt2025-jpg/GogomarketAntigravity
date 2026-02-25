import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'seller_api_client_provider.dart';

// ===================== STATE =====================

class SellerProductsState {
  final List<Product> products;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const SellerProductsState({
    this.products = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  SellerProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) =>
      SellerProductsState(
        products: products ?? this.products,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        error: clearError ? null : error ?? this.error,
      );
}

// ===================== NOTIFIER =====================

class SellerProductsNotifier extends StateNotifier<SellerProductsState> {
  final Ref _ref;

  SellerProductsNotifier(this._ref) : super(const SellerProductsState()) {
    loadMyProducts();
  }

  Future<void> loadMyProducts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final api = _ref.read(sellerApiClientProvider);
      final data = await api.getMySellerProducts();
      final List<dynamic> raw;
      if (data is Map && data.containsKey('items')) {
        raw = data['items'] as List<dynamic>;
      } else if (data is List) {
        raw = data as List<dynamic>;
      } else {
        raw = [];
      }
      final products = raw.map(_parse).toList();
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createProduct({
    required String title,
    required double price,
    required int stock,
    required String category,
    String? description,
    List<String>? imageUrls,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final api = _ref.read(sellerApiClientProvider);
      await api.createSellerProduct(
        title: title,
        price: price,
        stock: stock,
        category: category,
        description: description,
        imageUrls: imageUrls,
      );
      await loadMyProducts();
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateProduct({
    required String productId,
    required String title,
    required double price,
    required int stock,
    required String category,
    String? description,
    List<String>? imageUrls,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final api = _ref.read(sellerApiClientProvider);
      await api.updateSellerProduct(
        productId: productId,
        title: title,
        price: price,
        stock: stock,
        category: category,
        description: description,
        imageUrls: imageUrls,
      );
      await loadMyProducts();
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      final api = _ref.read(sellerApiClientProvider);
      await api.deleteSellerProduct(productId);
      state = state.copyWith(
        products: state.products.where((p) => p.id != productId).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<String?> uploadProductImage(String filePath) async {
    try {
      final api = _ref.read(sellerApiClientProvider);
      return await api.uploadImage(filePath);
    } catch (e) {
      state = state.copyWith(error: 'Ошибка загрузки фото: $e');
      return null;
    }
  }

  Product _parse(dynamic raw) {
    final m = raw as Map<String, dynamic>;
    return Product(
      id: m['id']?.toString() ?? '',
      title: m['title']?.toString() ?? m['name']?.toString() ?? 'Товар',
      price: (m['price'] as num?)?.toDouble() ?? 0,
      sellerId: m['sellerId']?.toString() ?? '',
      category: m['category']?.toString() ?? '',
      rating: (m['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (m['reviewCount'] as num?)?.toInt() ?? 0,
      isFeatured: m['isFeatured'] as bool? ?? false,
      description: m['description']?.toString(),
      stock: (m['stock'] as num?)?.toInt() ?? 0,
      imageUrls: (m['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

// ===================== PROVIDERS =====================

final sellerProductsProvider =
    StateNotifierProvider<SellerProductsNotifier, SellerProductsState>(
  (ref) => SellerProductsNotifier(ref),
);
