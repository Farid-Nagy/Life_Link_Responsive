import 'package:flutter/material.dart';

/// Central visual tokens for LifeLink.
/// Keep all shared colors here so the web UI stays consistent and lightweight.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF00A7B3);
  static const primaryDark = Color(0xFF008C96);
  static const primarySoft = Color(0xFFE6F7F8);
  static const primarySurface = Color(0xFFF1FBFB);
  static const primaryBackground = Color(0xFFEAF8F9);
  static const accent = Color(0xFF1FA5A9);
  static const accentLight = Color(0xFF27B4B8);

  // Backgrounds & surfaces
  static const background = Color(0xFFF5F6FA);
  static const pageBackground = Color(0xFFF7F7F8);
  static const surface = Colors.white;
  static const surfaceSoft = Color(0xFFFBFCFC);
  static const inputFill = Color(0xFFF8FAFA);
  static const inputFillLight = Color(0xFFF1F4F5);
  static const disabledSurface = Color(0xFFE3E7E9);

  // Text
  static const text = Color(0xFF172126);
  static const textSecondary = Color(0xFF43515A);
  static const muted = Color(0xFF7A878E);
  static const textOnPrimary = Colors.white;

  // Borders & dividers
  static const border = Color(0xFFE2E8EA);
  static const borderStrong = Color(0xFFC9D5D8);
  static const cardBorder = Color(0xFFE7C6C6);
  static const divider = Color(0xFFE5EAEC);

  // Feedback
  static const danger = Color(0xFFD92D20);
  static const success = Color(0xFF1A9A55);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);

  // Shadows
  static const shadow = Color(0x1A15252A);
  static const shadowSoft = Color(0x12000000);
  static const darkShadow = Color(0x26000000);

  // Utility
  static const black = Colors.black;
  static const black87 = Color(0xDE000000);
  static const black54 = Color(0x8A000000);
  static const grey = Color(0xFF9CA3AF);
  static const grey100 = Color(0xFFF3F4F6);
  static const white = Colors.white;
  static const white70 = Color(0xB3FFFFFF);
  static const transparent = Colors.transparent;
}
