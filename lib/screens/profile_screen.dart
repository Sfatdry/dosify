import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Obtenemos el usuario de la autenticación de Supabase
  final User? user = Supabase.instance.client.auth.currentUser;

  // Función para cerrar sesión correctamente
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
          SnackBar(content: Text("Error al cerrar sesión: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Datos dinámicos de Supabase
    final String userEmail = user?.email ?? "Email no disponible";
    final String userName = user?.userMetadata?['nombre'] ?? "Usuario de Dosify";
    
    // Extraer iniciales para el avatar
    String iniciales = "US";
    if (userName.isNotEmpty) {
      List<String> names = userName.split(" ");
      iniciales = names.length > 1 
          ? "${names[0][0]}${names[1][0]}".toUpperCase() 
          : names[0][0].toUpperCase();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F9F9), // Fondo pastel de tu Dashboard
      appBar: AppBar(
        title: const Text("Mi Perfil", 
          style: TextStyle(color: Color(0xFF2B889C), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            // Avatar Estilizado de la imagen (MG)
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF34D399), Color(0xFF059669)], // Verde esmeralda de la imagen
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF059669).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            iniciales,
                            style: const TextStyle(
                              fontSize: 36, 
                              color: Colors.white, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white, 
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
                          ),
                          child: const Icon(Icons.camera_alt, size: 20, color: Color(0xFF2B889C)),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(userName, 
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                  Text(userEmail, 
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Tarjetas de Información con diseño Dosify
            _buildInfoCard("Nombre de usuario", userName, Icons.person_outline),
            const SizedBox(height: 15),
            _buildInfoCard("Correo electrónico", userEmail, Icons.email_outlined),
            const SizedBox(height: 15),
            _buildInfoCard("Contraseña", "••••••••••••", Icons.lock_outline),
            
            const SizedBox(height: 40),
            
            // Botón Cerrar Sesión
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text("Cerrar Sesión", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5252),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2B889C), size: 22),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black12),
        ],
      ),
    );
  }
}