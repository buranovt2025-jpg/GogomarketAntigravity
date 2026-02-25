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
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isRegister = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authProvider.notifier);

    bool success;
    if (_isRegister) {
      success = await notifier.register(
        phone: _phoneCtrl.text.trim(),
        password: _passCtrl.text,
        name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      );
    } else {
      success = await notifier.login(
        phone: _phoneCtrl.text.trim(),
        password: _passCtrl.text,
      );
    }

    if (success && mounted) {
      context.go('/home');
    } else if (mounted) {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error ?? 'Ошибка'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                // Logo
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.shopping_bag_rounded,
                        color: Colors.white, size: 46),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'GOGOMARKET',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineXL.copyWith(
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ).createShader(const Rect.fromLTWH(0, 0, 300, 40)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isRegister ? 'Создайте аккаунт' : 'Войдите в аккаунт',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyM,
                ),
                const SizedBox(height: 40),
                // Name (only for register)
                if (_isRegister) ...[
                  GogoTextField(
                    label: 'Имя',
                    hint: 'Ваше имя',
                    controller: _nameCtrl,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  const SizedBox(height: 16),
                ],
                // Phone
                GogoTextField(
                  label: 'Номер телефона',
                  hint: '+998901234567',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Обязательное поле';
                    if (!v.startsWith('+')) return 'Формат: +998XXXXXXXXX';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Password
                GogoTextField(
                  label: 'Пароль',
                  hint: '••••••••',
                  controller: _passCtrl,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  validator: (v) {
                    if (v == null || v.length < 6) return 'Минимум 6 символов';
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                // Submit button
                GogoButton(
                  label: _isRegister ? 'Зарегистрироваться' : 'Войти',
                  isLoading: auth.isLoading,
                  fullWidth: true,
                  onPressed: _onSubmit,
                ),
                const SizedBox(height: 20),
                // Toggle register/login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isRegister
                          ? 'Уже есть аккаунт? '
                          : 'Нет аккаунта? ',
                      style: AppTextStyles.bodyM,
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isRegister = !_isRegister),
                      child: Text(
                        _isRegister ? 'Войти' : 'Зарегистрироваться',
                        style: AppTextStyles.labelM.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
