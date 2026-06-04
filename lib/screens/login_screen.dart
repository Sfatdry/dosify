import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_screen.dart';
import '../widgets/neumorphic_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, ingresa tu correo y contraseña"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // El StreamBuilder en main.dart detecta la sesión y navega automáticamente
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error inesperado: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color tealColor = Color(0xFF00ACC1);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F9F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/dosify_logo_hd.PNG',
                  width: 150,
                  height: 150,
                ),
              ),
              const SizedBox(height: 40),

              const Text(
                "Bienvenido",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006064),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Inicie sesión para continuar",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 40),

              // Input Correo
              NeumorphicInput(
                hintText: "Correo electrónico",
                icon: Icons.email_outlined,
                controller: _emailController,
              ),
              const SizedBox(height: 20),

              // Input Contraseña
              NeumorphicInput(
                hintText: "Contraseña",
                icon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
              ),

              const SizedBox(height: 40),

              // Botón Iniciar Sesión
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tealColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Iniciar Sesión",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              // Enlace a Registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿No tienes cuenta? ", style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    ),
                    child: const Text(
                      "Regístrate",
                      style: TextStyle(
                        color: tealColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}