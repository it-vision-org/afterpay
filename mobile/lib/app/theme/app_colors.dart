import 'package:flutter/material.dart';

/// AfterPay's palette — deep navy, royal blue, cyan/teal, mint. Premium,
/// modern fintech feel. Every screen should read colors from [AppTheme]'s
/// [ColorScheme] / [AppSemanticColors] rather than hard-coding hex values,
/// so the palette stays consistent and can be re-tuned from one place.
abstract final class AppColors {
  static const primary = Color(0xFF2946E0);
  static const primaryDark = Color(0xFF101B4A);
  static const primaryLight = Color(0xFFE3E9FF);
  static const accent = Color(0xFF14B8A6);

  static const background = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF0B1130);
  static const textSecondary = Color(0xFF5C6680);

  static const border = Color(0xFFE1E5F0);
  static const divider = Color(0xFFEAEDF6);

  /// Under budget / salary remaining comfortably positive.
  static const success = Color(0xFF10B981);

  /// Approaching or over budget — needs attention.
  static const warning = Color(0xFFF59E0B);

  static const error = Color(0xFFDC2626);
  static const info = Color(0xFF0EA5E9);

  static const shadow = Color(0xFF0B1130);
}
