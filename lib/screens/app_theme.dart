import 'package:flutter/material.dart';

class DosifyTheme {
  static const primaryCyan = Color(0xFF06B6D4);
  static const lightSky = Color(0xFFF0F9FF);
  static const borderSky = Color(0xFFBAE6FD);

  static InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryCyan),
      filled: true,
      fillColor: lightSky,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: borderSky),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: primaryCyan, width: 2),
      ),
    );
  }
}