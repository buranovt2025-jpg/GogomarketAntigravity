import 'package:flutter/material.dart';

/// GOGOMARKET Design System — Color Palette
abstract class AppColors {
  // === Primary ===
  static const Color primary = Color(0xFFFF6B00); // Насыщенный оранжевый
  static const Color primaryLight = Color(0xFFFF8F3F);
  static const Color primaryDark = Color(0xFFCC5500);

  // === Accent ===
  static const Color accent = Color(0xFFE94560); // Ярко-розовый
  static const Color accentLight = Color(0xFFFF6B80);

  // === Backgrounds (Dark theme) ===
  static const Color bgDark = Color(0xFF0F0F1A);      // Основной фон
  static const Color bgSurface = Color(0xFF1A1A2E);   // Карточки/сёрфейс
  static const Color bgCard = Color(0xFF242438);       // Карточки товаров
  static const Color bgOverlay = Color(0xFF2E2E45);   // Оверлеи

  // === Text ===
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C8);
  static const Color textHint = Color(0xFF6B6B85);
  static const Color textDisabled = Color(0xFF4A4A60);

  // === Status Colors ===
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // === Order Status Colors ===
  static const Color statusPending = Color(0xFFF39C12);
  static const Color statusDelivering = Color(0xFF3498DB);
  static const Color statusDelivered = Color(0xFF2ECC71);
  static const Color statusCancelled = Color(0xFFE74C3C);

  // === Components ===
  static const Color divider = Color(0xFF2E2E45);
  static const Color inputBorder = Color(0xFF3A3A55);
  static const Color bottomNav = Color(0xFF1A1A2E);
  static const Color shimmer = Color(0xFF2E2E45);

  // === Gradient ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [bgDark, bgSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
