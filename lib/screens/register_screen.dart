import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow; // IMPORTANTE: Ocultar originales
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart'; // IMPORTANTE: Usar nuevos
import '../theme/colors.dart';
import '../widgets/neumorphic_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  int _selectedAvatarIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DosifyColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: DosifyColors.primaryTeal),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
          child: Column(
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Crear Cuenta",
                        style: TextStyle(
                          color: DosifyColors.primaryTeal,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Únase a la red de cuidado Dosify",
                        style: TextStyle(color: DosifyColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                  const Icon(Icons.person_add_outlined, size: 50, color: DosifyColors.accentGreen),
                ],
              ),
              const SizedBox(height: 50),

              // Selector de Avatar
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Seleccione su perfil visual (Opcional)",
                  style: TextStyle(color: DosifyColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 15),
              _buildAvatarSelector(),
              const SizedBox(height: 40),

              // Inputs
              NeumorphicInput(
                hintText: "Nombre Completo",
                icon: Icons.person_outline,
                controller: _nameController,
              ),
              const SizedBox(height: 25),
              NeumorphicInput(
                hintText: "Correo Electrónico",
                icon: Icons.email_outlined,
                controller: _emailController,
              ),
              const SizedBox(height: 25),
              NeumorphicInput(
                hintText: "Contraseña de Acceso",
                icon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
              ),

              const SizedBox(height: 45),

              _buildPrimaryButton(text: "Finalizar Registro", onPressed: () {}),

              const SizedBox(height: 30),
              
              const Text(
                "Al registrarse, acepta nuestros Términos de Servicio y Política de Privacidad.",
                textAlign: TextAlign.center,
                style: TextStyle(color: DosifyColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        final List<IconData> avatarIcons = [
          Icons.face_retouching_natural,
          Icons.face_unlock_outlined,
          Icons.face_6_outlined,
          Icons.face_5_outlined,
        ];
        bool isSelected = _selectedAvatarIndex == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedAvatarIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: DosifyColors.backgroundColor,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: DosifyColors.accentGreen, width: 2) : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        blurRadius: 5,
                        offset: const Offset(3, 3),
                        color: Colors.black.withOpacity(0.1),
                        inset: true, // PROPIEDAD DE LA LIBRERÍA
                      ),
                      BoxShadow(
                        blurRadius: 5,
                        offset: const Offset(-3, -3),
                        color: Colors.white.withOpacity(0.7),
                        inset: true, // PROPIEDAD DE LA LIBRERÍA
                      ),
                    ]
                  : [
                      BoxShadow(
                        blurRadius: 8,
                        offset: const Offset(4, 4),
                        color: Colors.black.withOpacity(0.08),
                      ),
                      BoxShadow(
                        blurRadius: 8,
                        offset: const Offset(-4, -4),
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ],
            ),
            child: Icon(
              avatarIcons[index],
              size: 30,
              color: isSelected ? DosifyColors.accentGreen : DosifyColors.primaryTeal,
            ),
          ),
        );
      }),
    );
  }

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