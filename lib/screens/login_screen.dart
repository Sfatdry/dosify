import 'package:flutter/material.dart';
import 'register_screen.dart'; // Asegúrate de que el nombre del archivo sea correcto
import '../theme/colors.dart';
import '../widgets/neumorphic_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para capturar el texto
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Limpieza de controladores
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Función para manejar el inicio de sesión
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

    // Simulación de inicio de sesión exitoso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("¡Bienvenido de nuevo, $username!"),
        backgroundColor: DosifyColors.primaryTeal,
      ),
    );

    // Aquí navegarías a la pantalla principal (Home/Dashboard)
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigation()));
  }

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
              // Logo de la App
              Image.asset(
                'assets/logo_dosify.png',
                height: 100,
                // Si el logo falla, muestra un icono médico por defecto
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.medical_information, size: 100, color: DosifyColors.primaryTeal),
              ),
              const SizedBox(height: 40),
              
              const Text(
                "Bienvenido",
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: DosifyColors.primaryTeal
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Inicie sesión para continuar",
                style: TextStyle(color: DosifyColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 40),
              
              // Input de Usuario
              NeumorphicInput(
                hintText: "Nombre de Usuario", 
                icon: Icons.person_outline, 
                controller: _userController
              ),
              const SizedBox(height: 20),
              
              // Input de Contraseña (El widget NeumorphicInput ahora gestiona el ojo)
              NeumorphicInput(
                hintText: "Contraseña", 
                icon: Icons.lock_outline, 
                isPassword: true, 
                controller: _passwordController
              ),
              
              const SizedBox(height: 40),
              
              // Botón de Inicio de Sesión
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DosifyColors.primaryTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Iniciar Sesión", 
                    style: TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 16
                    )
                  ),
                ),
              ),
              
              const SizedBox(height: 30),

              // Enlace para ir a la pantalla de Registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "¿No tienes cuenta? ",
                    style: TextStyle(color: DosifyColors.textSecondary),
                  ),
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
                        color: DosifyColors.primaryTeal,
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