import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Obtenemos el usuario real de Supabase
  final User? user = Supabase.instance.client.auth.currentUser;

  // Función para cerrar sesión
  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  // Estilo de los campos de texto
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF2B889C)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE0F2F1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Datos dinámicos
    final String userEmail = user?.email ?? "Email no disponible";
    final String userName = user?.userMetadata?['nombre'] ?? "Usuario de Dosify";

    return Scaffold(
      backgroundColor: const Color(0xFFF1F9F9),
      appBar: AppBar(
        title: const Text("Mi Perfil", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B889C))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Tarjeta de Estadística (Diseño UsuarioPage)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                border: Border.all(color: const Color(0xFFB2EBF2).withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Tratamientos activos", style: TextStyle(color: Colors.grey)),
                      Text("3", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2B889C))),
                    ],
                  ),
                  const Icon(Icons.analytics_outlined, size: 45, color: Color(0xFF5AB396)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 2. Formulario de Edición
            TextField(
              controller: TextEditingController(text: userName),
              decoration: _inputStyle("Nombre Completo", Icons.person_outline),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: TextEditingController(text: userEmail),
              decoration: _inputStyle("Correo Electrónico", Icons.mail_outline),
            ),
            const SizedBox(height: 15),
            TextField(
              obscureText: true,
              decoration: _inputStyle("Contraseña", Icons.lock_outline),
            ),
            
            const SizedBox(height: 30),

            // 3. Botón Guardar
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B889C),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text("Guardar Cambios", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 20),

            // 4. Botón Cerrar Sesión (Diseño ProfileScreen anterior)
            TextButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout, color: Color(0xFFFF5252)),
              label: const Text("Cerrar Sesión", style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}