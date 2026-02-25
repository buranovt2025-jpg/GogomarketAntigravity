import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/cart_provider.dart';
import '../../providers/products_provider.dart';

final _categories = ['Все', 'Одежда', 'Электроника', 'Обувь', 'Декор', 'Еда'];

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  int _selectedCategory = 0;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Debounce search
    _searchCtrl.addListener(() {
      _debounce?.cancel();
      _debounce = Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ref.read(productsProvider.notifier).setSearch(_searchCtrl.text);
        }
      });
    });
  }

  Future<void>? _debounce;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text('Каталог', style: AppTextStyles.headlineM),
        actions: [
          if (productsState.isLoading && productsState.products.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.textSecondary,
            onPressed: () => ref.read(productsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.bgSurface,
        onRefresh: () => ref.read(productsProvider.notifier).refresh(),
        child: Column(
          children: [
            // === Search ===
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchCtrl,
                style: AppTextStyles.bodyL,
                decoration: InputDecoration(
                  hintText: 'Поиск товаров...',
                  hintStyle: AppTextStyles.bodyM,
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textHint, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              color: AppColors.textHint, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref
                                .read(productsProvider.notifier)
                                .setSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.bgCard,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // === Categories ===
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = i);
                      ref
                          .read(productsProvider.notifier)
                          .setCategory(_categories[i]);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: _selectedCategory == i
                            ? AppColors.primaryGradient
                            : null,
                        color: _selectedCategory == i
                            ? null
                            : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _categories[i],
                        style: AppTextStyles.labelM.copyWith(
                          color: _selectedCategory == i
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // === Error banner ===
            if (productsState.error != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(productsState.error!,
                          style: AppTextStyles.bodyS
                              .copyWith(color: AppColors.error)),
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.read(productsProvider.notifier).refresh(),
                      child: Text('Retry',
                          style: AppTextStyles.labelS
                              .copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            // === Grid ===
            Expanded(
              child: productsState.isLoading && productsState.products.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : productsState.products.isEmpty
                      ? _emptyState()
                      : NotificationListener<ScrollNotification>(
                          onNotification: (sn) {
                            if (sn is ScrollEndNotification &&
                                sn.metrics.extentAfter < 200 &&
                                productsState.hasMore &&
                                !productsState.isLoading) {
                              ref
                                  .read(productsProvider.notifier)
                                  .loadProducts();
                            }
                            return false;
                          },
                          child: GridView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.68,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: productsState.products.length +
                                (productsState.hasMore ? 1 : 0),
                            itemBuilder: (context, i) {
                              if (i >= productsState.products.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                        strokeWidth: 2),
                                  ),
                                );
                              }
                              final product = productsState.products[i];
                              return GogoProductCard(
                                product: product,
                                onAddToCart: () {
                                  ref
                                      .read(cartProvider.notifier)
                                      .addProduct(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                              Icons.check_circle_rounded,
                                              color: Colors.white,
                                              size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${product.title} добавлен',
                                              style: AppTextStyles.labelM,
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: AppColors.success,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    final hasFilters = _searchCtrl.text.isNotEmpty || _selectedCategory > 0;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(hasFilters ? '🔍' : '📦',
              style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(
            hasFilters ? 'Ничего не найдено' : 'Товары не загружены',
            style: AppTextStyles.headlineM,
          ),
          const SizedBox(height: 6),
          Text(
            hasFilters
                ? 'Попробуйте другой запрос'
                : 'Потяните вниз чтобы обновить',
            style: AppTextStyles.bodyM,
          ),
        ],
      ),
    );
  }
}
