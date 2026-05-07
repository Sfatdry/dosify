import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  // ESTA LÍNEA ES LA QUE ELIMINA EL ERROR EN EL MAIN
  const SplashScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Si ya tienes el logo en assets, usa Image.asset
            // Si no, usa un icono temporal para que no falle al compilar
            const Icon(Icons.favorite, size: 100, color: Color(0xFF00ACC1)),
            const SizedBox(height: 20),
            const Text(
              "Dosify",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00ACC1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

