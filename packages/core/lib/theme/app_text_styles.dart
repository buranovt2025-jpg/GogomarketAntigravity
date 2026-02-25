import 'package:flutter/material.dart';

/// GOGOMARKET Design System — Typography
///
/// Использует Inter (системный/Google Fonts fallback).
/// Применяй через Theme.of(context).textTheme ИЛИ напрямую AppTextStyles.*
abstract class AppTextStyles {
  // === Headlines ===
  static const TextStyle headlineXL = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: Color(0xFFFFFFFF),
  );

  static const TextStyle headlineL = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: Color(0xFFFFFFFF),
  );

  static const TextStyle headlineM = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: Color(0xFFFFFFFF),
  );

  static const TextStyle headlineS = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    color: Color(0xFFFFFFFF),
  );

  // === Body ===
  static const TextStyle bodyL = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Color(0xFFFFFFFF),
  );

  static const TextStyle bodyM = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFFB0B0C8),
  );

  static const TextStyle bodyS = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFFB0B0C8),
  );

  // === Labels ===
  static const TextStyle labelL = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Color(0xFFFFFFFF),
  );

  static const TextStyle labelM = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: Color(0xFFFFFFFF),
  );

  static const TextStyle labelS = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    color: Color(0xFFB0B0C8),
  );

  // === Price ===
  static const TextStyle priceL = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: Color(0xFFFF6B00),
  );

  static const TextStyle priceM = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Color(0xFFFF6B00),
  );

  // === Button ===
  static const TextStyle button = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: Color(0xFFFFFFFF),
  );
}
