import 'package:flutter/material.dart';
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
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegistration() {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos"), backgroundColor: Colors.redAccent),
      );
      return;
    }
    
    // Simulación de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("¡Cuenta creada con éxito!"), backgroundColor: DosifyColors.accentGreen),
    );
    Navigator.pop(context); // Vuelve al login
  }

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
              Image.asset('assets/logo_dosify.png', height: 80),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Crear Cuenta", style: TextStyle(color: DosifyColors.primaryTeal, fontSize: 28, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text("Únase a la red de cuidado Dosify", style: TextStyle(color: DosifyColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                  const Icon(Icons.person_add_outlined, size: 50, color: DosifyColors.accentGreen),
                ],
              ),
              const SizedBox(height: 30),
              _buildAvatarSelector(),
              const SizedBox(height: 30),
              NeumorphicInput(hintText: "Nombre Completo", icon: Icons.person_outline, controller: _nameController),
              const SizedBox(height: 20),
              NeumorphicInput(hintText: "Correo Electrónico", icon: Icons.email_outlined, controller: _emailController),
              const SizedBox(height: 20),
              NeumorphicInput(hintText: "Contraseña", icon: Icons.lock_outline, isPassword: true, controller: _passwordController),
              const SizedBox(height: 40),
              
              _buildPrimaryButton(text: "Finalizar Registro", onPressed: _handleRegistration),
              
              const SizedBox(height: 20),
              // ENLACE PARA VOLVER AL LOGIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿Ya tienes cuenta? ", style: TextStyle(color: DosifyColors.textSecondary)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text("Inicia sesión", style: TextStyle(color: DosifyColors.primaryTeal, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
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
        final icons = [Icons.face, Icons.face_5, Icons.face_6, Icons.face_retouching_natural];
        bool isSelected = _selectedAvatarIndex == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedAvatarIndex = index),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? DosifyColors.primaryTeal.withOpacity(0.1) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? DosifyColors.accentGreen : Colors.transparent, width: 2),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Icon(icons[index], color: isSelected ? DosifyColors.accentGreen : DosifyColors.primaryTeal, size: 30),
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
        gradient: const LinearGradient(colors: [DosifyColors.primaryTeal, DosifyColors.accentGreen]),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
