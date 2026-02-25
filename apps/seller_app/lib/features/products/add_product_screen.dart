import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/seller_products_provider.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  final Product? existingProduct; // null = добавление, !null = редактирование

  const AddProductScreen({super.key, this.existingProduct});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  String _selectedCategory = 'Одежда';

  // Image picker
  final _picker = ImagePicker();
  final List<File> _localImages = [];
  final List<String> _uploadedUrls = []; // уже загруженные на сервер URL
  bool _isUploadingImage = false;

  final _categories = [
    'Одежда',
    'Электроника',
    'Обувь',
    'Декор',
    'Еда',
    'Другое'
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    if (p != null) {
      _titleCtrl.text = p.title;
      _priceCtrl.text = p.price.toStringAsFixed(0);
      _descCtrl.text = p.description ?? '';
      _stockCtrl.text = '${p.stock}';
      _selectedCategory = p.category.isNotEmpty ? p.category : 'Другое';
      _uploadedUrls.addAll(p.imageUrls ?? []);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (xFile == null) return;

    setState(() {
      _isUploadingImage = true;
      _localImages.add(File(xFile.path));
    });

    // Загружаем на сервер
    final url = await ref
        .read(sellerProductsProvider.notifier)
        .uploadProductImage(xFile.path);

    setState(() {
      _isUploadingImage = false;
      if (url != null) _uploadedUrls.add(url);
    });
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(sellerProductsProvider.notifier);
    final isEdit = widget.existingProduct != null;

    bool success;
    if (isEdit) {
      success = await notifier.updateProduct(
        productId: widget.existingProduct!.id,
        title: _titleCtrl.text.trim(),
        price: double.parse(_priceCtrl.text),
        stock: int.parse(_stockCtrl.text),
        category: _selectedCategory,
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        imageUrls: _uploadedUrls.isNotEmpty ? _uploadedUrls : null,
      );
    } else {
      success = await notifier.createProduct(
        title: _titleCtrl.text.trim(),
        price: double.parse(_priceCtrl.text),
        stock: int.parse(_stockCtrl.text),
        category: _selectedCategory,
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        imageUrls: _uploadedUrls.isNotEmpty ? _uploadedUrls : null,
      );
    }

    if (mounted) {
      final stateErr = ref.read(sellerProductsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? '✅ Товар ${isEdit ? 'обновлён' : 'добавлен'}!'
            : stateErr ?? 'Ошибка'),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      if (success) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sellerProductsProvider);
    final isEdit = widget.existingProduct != null;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text(
          isEdit ? 'Редактировать товар' : 'Новый товар',
          style: AppTextStyles.headlineM,
        ),
        leading: BackButton(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Image picker ===
              Text('Фотографии', style: AppTextStyles.labelM),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Add button
                    GestureDetector(
                      onTap: _isUploadingImage ? null : _pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: _isUploadingImage
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.primary, strokeWidth: 2))
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_photo_alternate_outlined,
                                      color: AppColors.textHint, size: 32),
                                  const SizedBox(height: 4),
                                  Text('Добавить',
                                      style: AppTextStyles.bodyS
                                          .copyWith(color: AppColors.textHint)),
                                ],
                              ),
                      ),
                    ),
                    // Local preview images
                    ..._localImages.map((file) => Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(file),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )),
                    // Already-uploaded URL images
                    ..._uploadedUrls.map((url) => Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(url),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // === Title ===
              GogoTextField(
                label: 'Название товара *',
                hint: 'Nike Air Max 2024',
                controller: _titleCtrl,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Обязательное поле' : null,
              ),
              const SizedBox(height: 16),
              // === Category ===
              Text('Категория', style: AppTextStyles.labelM),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: AppColors.bgSurface,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textHint),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    style: AppTextStyles.bodyL,
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCategory = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // === Price + Stock ===
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GogoTextField(
                      label: 'Цена (сум) *',
                      hint: '299000',
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.attach_money_rounded),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Обязательное';
                        if (double.tryParse(v) == null) return 'Число';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GogoTextField(
                      label: 'Кол-во *',
                      hint: '10',
                      controller: _stockCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Обяз.';
                        if (int.tryParse(v) == null) return 'Число';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // === Description ===
              GogoTextField(
                label: 'Описание',
                hint: 'Расскажите о вашем товаре...',
                controller: _descCtrl,
                maxLines: 4,
              ),
              // === Error ===
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(state.error!,
                      style:
                          AppTextStyles.bodyS.copyWith(color: AppColors.error)),
                ),
              ],
              const SizedBox(height: 28),
              // === Save ===
              GogoButton(
                label: isEdit ? 'Сохранить изменения' : 'Добавить товар',
                isLoading: state.isSaving,
                fullWidth: true,
                icon: Icon(
                  isEdit
                      ? Icons.save_rounded
                      : Icons.add_circle_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _onSave,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
