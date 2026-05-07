import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DosifyTheme {
  // Colores extraídos de tu diseño
  static const Color azulPrincipal = Color(0xFF004A99);
  static const Color turquesa = Color(0xFF00C2CB);
  static const Color fondoGris = Color(0xFFF8FAFC);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: azulPrincipal,
        primary: azulPrincipal,
        secondary: turquesa,
        surface: fondoGris,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(), // Fuente moderna similar a tu diseño
      scaffoldBackgroundColor: fondoGris,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
