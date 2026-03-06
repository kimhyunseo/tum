import 'package:flutter/material.dart';

class AppColors {
  // Primary Color Scale (Forest Green)
  static const Color primary50 = Color(0xFFE8F5E9);
  static const Color primary100 = Color(0xFFC8E6C9);
  static const Color primary200 = Color(0xFFA5D6A7);
  static const Color primary300 = Color(0xFF81C784);
  static const Color primary400 = Color(0xFF66BB6A);
  static const Color primary500 = Color(0xFF4CAF50);
  static const Color primary600 = Color(0xFF43A047);
  static const Color primary700 = Color(0xFF388E3C);
  static const Color primary800 = Color(0xFF2E7D32); // Main Forest Green
  static const Color primary900 = Color(0xFF1B5E20);

  // Alias for existing code compatibility
  static const Color primary = primary800;
  static const Color primaryLight = primary300;
  static const Color primaryDark = primary900;
  static const Color secondary = primary50;
  static const Color background = Color(0xFFF8FAF8);
  static const Color surface = Colors.white;

  // 포인트 컬러 (절약/저축 등)
  static const Color savings = Color(0xFF0D47A1);
  static const Color savingsLight = Color(0xFFE3F2FD);

  // 상태 컬러
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFBC02D);

  // 텍스트 및 중립 컬러
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color divider = Color(0xFFE0E0E0);
}
