import 'package:flutter/material.dart';

class AppColors {
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color cyan600 = Color(0xFF0891B2);
  static const Color cyan900 = Color(0xFF164E63);
  static const Color sky50 = Color(0xFFF0F9FF);
  static const Color sky200 = Color(0xFFBAE6FD);
}

// Decoración común para los inputs
InputDecoration customInputDecoration({required String hintText, IconData? icon}) {
  return InputDecoration(
    hintText: hintText,
    prefixIcon: icon != null ? Icon(icon, color: AppColors.cyan600) : null,
    filled: true,
    fillColor: AppColors.sky50,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.sky200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.sky200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.cyan500, width: 2),
    ),
  );
}