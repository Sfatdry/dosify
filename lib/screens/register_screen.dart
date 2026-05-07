import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para los campos de la tabla 'usuario'
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    // Validación básica de campos
    if (_nombreController.text.trim().isEmpty || 
        _emailController.text.trim().isEmpty || 
        _passwordController.text.isEmpty) {
      _mostrarSnackBar("Por favor, completa todos los campos", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Registro en la autenticación de Supabase
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {'nombre': _nombreController.text.trim()}, // Metadatos opcionales
      );

      if (res.user != null) {
        // 2. Inserción manual en la tabla 'usuario' según tu esquema
        await Supabase.instance.client.from('usuario').insert({
          'id': res.user!.id, // UUID generado por Auth
          'nombre': _nombreController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text, // Nota: Auth ya la encripta, esto es opcional si tu tabla lo requiere
        });

        if (mounted) {
          _mostrarSnackBar("¡Registro exitoso! Por favor inicia sesión", Colors.green);
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const LoginScreen())
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) _mostrarSnackBar(e.message, Colors.red);
    } catch (e) {
      if (mounted) _mostrarSnackBar("Ocurrió un error inesperado", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC0E5F0), Color(0xFFC4E8C2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25.0),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add, size: 60, color: Color(0xFF2B889C)),
                  const SizedBox(height: 10),
                  const Text(
                    "Crear Cuenta",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2B889C)),
                  ),
                  const SizedBox(height: 30),
                  
                  // Campo: nombre
                  _buildTextField(_nombreController, "Nombre Completo", Icons.person_outline),
                  const SizedBox(height: 15),
                  
                  // Campo: email
                  _buildTextField(_emailController, "Correo Electrónico", Icons.email_outlined, TextInputType.emailAddress),
                  const SizedBox(height: 15),
                  
                  // Campo: password
                  _buildTextField(_passwordController, "Contraseña", Icons.lock_outline, TextInputType.text, true),
                  
                  const SizedBox(height: 30),
                  _buildRegisterButton(),
                  
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("¿Ya tienes cuenta? Inicia sesión", style: TextStyle(color: Color(0xFF3A7C91))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, [TextInputType type = TextInputType.text, bool isPass = false]) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2B889C)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2B889C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : const Text("Registrarse", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}