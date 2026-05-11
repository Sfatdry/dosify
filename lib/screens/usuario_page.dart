import 'package:flutter/material.dart';
import 'app_theme.dart';

class UsuarioPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Tarjeta de Estadística
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                border: Border.all(color: DosifyTheme.borderSky),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Tratamientos activos", style: TextStyle(color: Colors.grey)),
                      Text("3", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: DosifyTheme.primaryCyan)),
                    ],
                  ),
                  const Icon(Icons.analytics_outlined, size: 40, color: DosifyTheme.primaryCyan),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Campos del Formulario
            TextField(decoration: DosifyTheme.inputDecoration("Nombre Completo", Icons.person_outline)),
            const SizedBox(height: 15),
            TextField(decoration: DosifyTheme.inputDecoration("Correo Electrónico", Icons.mail_outline)),
            const SizedBox(height: 15),
            TextField(
              obscureText: true,
              decoration: DosifyTheme.inputDecoration("Contraseña", Icons.lock_outline),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: DosifyTheme.primaryCyan,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Guardar Cambios", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}