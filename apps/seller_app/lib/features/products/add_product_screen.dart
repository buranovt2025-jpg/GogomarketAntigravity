import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

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
  bool _isLoading = false;

  final _categories = ['Одежда', 'Электроника', 'Обувь', 'Декор', 'Еда', 'Другое'];

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    if (p != null) {
      _titleCtrl.text = p.title;
      _priceCtrl.text = p.price.toStringAsFixed(0);
      _descCtrl.text = p.description ?? '';
      _stockCtrl.text = '${p.stock}';
      _selectedCategory = p.category;
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

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800)); // mock API call
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Товар ${widget.existingProduct == null ? 'добавлен' : 'обновлён'}!',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // === Image picker area ===
              GestureDetector(
                onTap: () {
                  // TODO: image_picker
                },
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.inputBorder,
                        style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate_outlined,
                          color: AppColors.textHint, size: 44),
                      const SizedBox(height: 10),
                      Text('Добавить фото',
                          style: AppTextStyles.labelM
                              .copyWith(color: AppColors.textHint)),
                      const SizedBox(height: 4),
                      Text('Нажмите чтобы выбрать из галереи',
                          style: AppTextStyles.bodyS),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCategory = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // === Price + Stock row ===
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
              const SizedBox(height: 32),
              // === Save ===
              GogoButton(
                label: isEdit ? 'Сохранить изменения' : 'Добавить товар',
                isLoading: _isLoading,
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
