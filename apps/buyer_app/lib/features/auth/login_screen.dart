import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController(text: '+998 ');
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authProvider.notifier).login(
          phone: _phoneCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(authProvider).error ?? 'Ошибка входа',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    // GoRouter автоматически редиректит на /home после успешного логина
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

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
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.45),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 20),
                Text('GogoMarket', style: AppTextStyles.headlineXL),
                const SizedBox(height: 6),
                Text(
                  'Лучший маркетплейс Узбекистана 🇺🇿',
                  style: AppTextStyles.bodyM,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 44),
                // === Fields ===
                GogoTextField(
                  label: 'Номер телефона',
                  hint: '+998 90 123 45 67',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_rounded),
                  validator: (v) =>
                      (v == null || v.trim().length < 9) ? 'Введите номер' : null,
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
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: Text('Забыли пароль?',
                        style: AppTextStyles.labelM
                            .copyWith(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 28),
                GogoButton(
                  label: 'Войти',
                  isLoading: isLoading,
                  fullWidth: true,
                  onPressed: _onLogin,
                ),
                const SizedBox(height: 14),
                GogoButton(
                  label: 'Зарегистрироваться',
                  variant: GogoButtonVariant.ghost,
                  fullWidth: true,
                  onPressed: () {},
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
