// En lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/neumorphic_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController(); // Cambiado a Usuario
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DosifyColors.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo_dosify.png', height: 100), // Logo oficial
              const SizedBox(height: 40),
              const Text(
                "Bienvenido",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: DosifyColors.primaryTeal),
              ),
              const SizedBox(height: 40),
              
              // Input de Usuario
              NeumorphicInput(
                hintText: "Nombre de Usuario", 
                icon: Icons.person_outline, 
                controller: _userController
              ),
              const SizedBox(height: 20),
              
              // Input de Contraseña
              NeumorphicInput(
                hintText: "Contraseña", 
                icon: Icons.lock_outline, 
                isPassword: true, 
                controller: _passwordController
              ),
              
              const SizedBox(height: 40),
              
              // Botón de Inicio de Sesión mejorado
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    print("Iniciando sesión con: ${_userController.text}");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DosifyColors.primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Iniciar Sesión", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}