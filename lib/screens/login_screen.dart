import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/neumorphic_input.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DosifyColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              // --- EL LOGO DE LA TERCERA IMAGEN ---
              Image.asset(
                'assets/logo_dosify.png',
                height: 120, // Un tamaño elegante y visible
              ),
              const SizedBox(height: 10),
              // Subtítulo formal
              const Text(
                "Gestión Inteligente de Medicación",
                style: TextStyle(
                  color: DosifyColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 60),

              // --- CAMPOS DE ENTRADA NEUMÓRFICOS ---
              NeumorphicInput(
                hintText: "Correo Electrónico",
                icon: Icons.email_outlined,
                controller: _emailController,
              ),
              const SizedBox(height: 25),
              NeumorphicInput(
                hintText: "Contraseña",
                icon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
              ),

              // Opciones secundarias formales
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "¿Olvidó su contraseña?",
                    style: TextStyle(color: DosifyColors.primaryTeal, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 35),

              // --- BOTÓN PRINCIPAL CON DEGRADADO ---
              _buildPrimaryButton(text: "Iniciar Sesión", onPressed: () {}),

              const SizedBox(height: 50),

              // Enlace de registro formal
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿No tiene una cuenta?",
                      style: TextStyle(color: DosifyColors.textSecondary, fontSize: 14)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    },
                    child: const Text(
                      "Regístrese aquí",
                      style: TextStyle(
                          color: DosifyColors.primaryTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
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

  // Widget reutilizable para el botón principal formal
  Widget _buildPrimaryButton({required String text, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [DosifyColors.primaryTeal, DosifyColors.accentGreen],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: DosifyColors.primaryTeal.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}