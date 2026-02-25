import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

class CourierLoginScreen extends ConsumerStatefulWidget {
  const CourierLoginScreen({super.key});

  @override
  ConsumerState<CourierLoginScreen> createState() => _CourierLoginScreenState();
}

class _CourierLoginScreenState extends ConsumerState<CourierLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/deliveries');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 60),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.info.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.delivery_dining_rounded,
                      color: Colors.white, size: 44),
                ),
                const SizedBox(height: 24),
                Text('Приложение курьера', style: AppTextStyles.headlineXL),
                const SizedBox(height: 8),
                Text('GogoMarket Delivery', style: AppTextStyles.bodyM),
                const SizedBox(height: 48),
                GogoTextField(
                  label: 'Телефон',
                  hint: '+998 90 000 00 00',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_rounded),
                  validator: (v) => (v?.isEmpty ?? true) ? 'Обязательное поле' : null,
                ),
                const SizedBox(height: 16),
                GogoTextField(
                  label: 'Пароль',
                  controller: _passwordCtrl,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_rounded),
                  validator: (v) => (v == null || v.length < 4) ? 'Минимум 4 символа' : null,
                ),
                const SizedBox(height: 32),
                GogoButton(
                  label: 'Войти',
                  isLoading: _isLoading,
                  fullWidth: true,
                  onPressed: _onLogin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
