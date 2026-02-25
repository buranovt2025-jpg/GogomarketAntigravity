import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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
    await Future.delayed(const Duration(seconds: 1)); // mock delay
    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/home');
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
                // === Logo ===
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text('GogoMarket', style: AppTextStyles.headlineXL),
                const SizedBox(height: 8),
                Text(
                  'Лучший маркетплейс Узбекистана',
                  style: AppTextStyles.bodyM,
                ),
                const SizedBox(height: 48),
                // === Form ===
                GogoTextField(
                  label: 'Номер телефона',
                  hint: '+998 90 123 45 67',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_rounded),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Введите номер' : null,
                ),
                const SizedBox(height: 16),
                GogoTextField(
                  label: 'Пароль',
                  hint: '••••••••',
                  controller: _passwordCtrl,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_rounded),
                  validator: (v) =>
                      (v == null || v.length < 4) ? 'Минимум 4 символа' : null,
                ),
                const SizedBox(height: 32),
                GogoButton(
                  label: 'Войти',
                  isLoading: _isLoading,
                  fullWidth: true,
                  onPressed: _onLogin,
                ),
                const SizedBox(height: 16),
                GogoButton(
                  label: 'Зарегистрироваться',
                  variant: GogoButtonVariant.ghost,
                  fullWidth: true,
                  onPressed: () {
                    // TODO: registration screen
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
