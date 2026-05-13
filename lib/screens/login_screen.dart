import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'main_navigation.dart'; 
import '../widgets/neumorphic_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- FUNCIÓN CORREGIDA ---
  void _handleLogin() {
    String username = _userController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, ingresa tu usuario y contraseña"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 1. Quitamos el 'const' de MainNavigation
    // 2. Le pasamos el texto de '_userController' como userName
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigation(userName: username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos una variable para el color por si acaso DosifyColors falla
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
              const Icon(Icons.medical_services, size: 100, color: tealColor),
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
              
              // Input Usuario
              NeumorphicInput(
                hintText: "Nombre de Usuario", 
                icon: Icons.person_outline, 
                controller: _userController,
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
              
              // Botón de Inicio de Sesión
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleLogin, // Llamamos a la función corregida
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tealColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: const Text(
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
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