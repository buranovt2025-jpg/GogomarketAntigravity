import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'api_client_provider.dart';

// ===================== STATE =====================

class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final int page;
  final bool hasMore;
  final String? selectedCategory;
  final String? searchQuery;

  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
    this.selectedCategory,
    this.searchQuery,
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    int? page,
    bool? hasMore,
    String? selectedCategory,
    String? searchQuery,
    bool clearError = false,
  }) =>
      ProductsState(
        products: products ?? this.products,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        selectedCategory: selectedCategory ?? this.selectedCategory,
        searchQuery: searchQuery ?? this.searchQuery,
      );
}

// ===================== NOTIFIER =====================

class ProductsNotifier extends StateNotifier<ProductsState> {
  final Ref _ref;

  ProductsNotifier(this._ref) : super(const ProductsState()) {
    loadProducts();
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (state.isLoading) return;

    final page = refresh ? 1 : state.page;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final api = _ref.read(apiClientProvider);
      final data = await api.getProducts(
        category: state.selectedCategory,
        search: state.searchQuery,
        page: page,
        limit: 20,
      );

      // API может возвращать {items: [], total: N} или просто []
      final List<dynamic> rawItems;
      if (data is Map && data.containsKey('items')) {
        rawItems = data['items'] as List<dynamic>;
      } else if (data is List) {
        rawItems = data as List<dynamic>;
      } else {
        rawItems = [];
      }

      final newProducts = rawItems.map(_parseProduct).toList();
      final allProducts = refresh
          ? newProducts
          : [...state.products, ...newProducts];

      state = state.copyWith(
        products: allProducts,
        isLoading: false,
        page: page + 1,
        hasMore: newProducts.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setCategory(String? category) async {
    state = state.copyWith(
      selectedCategory: category == 'Все' ? null : category,
      products: [],
      page: 1,
      hasMore: true,
    );
    await loadProducts(refresh: true);
  }

  Future<void> setSearch(String query) async {
    state = state.copyWith(
      searchQuery: query.isEmpty ? null : query,
      products: [],
      page: 1,
      hasMore: true,
    );
    await loadProducts(refresh: true);
  }

  Future<void> refresh() => loadProducts(refresh: true);

  Product _parseProduct(dynamic raw) {
    final m = raw as Map<String, dynamic>;
    return Product(
      id: m['id']?.toString() ?? '',
      title: m['title']?.toString() ?? m['name']?.toString() ?? 'Товар',
      price: (m['price'] as num?)?.toDouble() ?? 0,
      sellerId: m['sellerId']?.toString() ?? m['seller']?['id']?.toString() ?? '',
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

final productsProvider =
    StateNotifierProvider<ProductsNotifier, ProductsState>(
  (ref) => ProductsNotifier(ref),
);

/// Удобные derived-providers
final productsListProvider = Provider<List<Product>>((ref) {
  return ref.watch(productsProvider).products;
});

final productsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(productsProvider).isLoading;
});

final productsErrorProvider = Provider<String?>((ref) {
  return ref.watch(productsProvider).error;
});
