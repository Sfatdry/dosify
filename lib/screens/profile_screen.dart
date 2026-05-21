import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;

  const ProfileScreen({super.key, required this.userName});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  User? user;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    user = supabase.auth.currentUser;
    
    // CONEXIÓN CON BD: Obtenemos el nombre de los metadatos si existe, sino usamos el prop
    String displayName = user?.userMetadata?['full_name'] ?? widget.userName;
    
    _nameController = TextEditingController(text: displayName);
    _emailController = TextEditingController(text: user?.email ?? "");
    _passwordController = TextEditingController(text: "********");
  }

  // FUNCIÓN PARA GUARDAR EN BASE DE DATOS
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      // Actualizamos los metadatos del usuario en Supabase Auth
      await supabase.auth.updateUser(
        UserAttributes(
          data: {'full_name': _nameController.text},
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Perfil actualizado con éxito!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  InputDecoration _inputStyle(String label, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF00ACC1), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF0F9FF),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFBAE6FD))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFBAE6FD))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF00ACC1), width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // ¡OJO! SIN AppBar aquí para que no se duplique con el de MainNavigation
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04), 
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Encabezado Interno del Perfil (Estilo Tarjeta)
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFF00ACC1), borderRadius: BorderRadius.circular(15)),
                          child: const Icon(Icons.person, color: Colors.white, size: 32),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            width: 13, height: 13,
                            decoration: BoxDecoration(color: const Color(0xFF00C853), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Perfil de Usuario", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
                        Text("Administra tu información personal", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 35),

                // CAMPOS DEL FORMULARIO
                const Text("Nombre completo", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF006064), fontSize: 14)),
                const SizedBox(height: 8),
                TextField(controller: _nameController, decoration: _inputStyle("Nombre", Icons.person_outline)),
                
                const SizedBox(height: 24),
                const Text("Correo electrónico", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF006064), fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController, 
                  readOnly: true, // El email lo gestiona Supabase Auth directamente
                  decoration: _inputStyle("Email", Icons.mail_outline),
                ),
                
                const SizedBox(height: 24),
                const Text("Contraseña", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF006064), fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController, 
                  obscureText: _obscurePassword,
                  decoration: _inputStyle(
                    "Password", 
                    Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF00ACC1)),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // BOTÓN DE GUARDAR CON ESTADO DE CARGA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00ACC1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Guardar Cambios", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                
                const SizedBox(height: 20),
                Center(
                  child: TextButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                    label: const Text("Cerrar Sesión", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}