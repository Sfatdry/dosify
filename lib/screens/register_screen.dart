import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/neumorphic_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para capturar el texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Variable para el avatar (índice seleccionado)
  int _selectedAvatarIndex = -1;

  @override
  void dispose() {
    // Es buena práctica limpiar los controladores al cerrar la pantalla
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Función para manejar el registro
  void _handleRegistration() {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;

    // Validación básica
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, completa todos los campos"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedAvatarIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, selecciona un avatar"),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    // Aquí ya tienes los datos listos para enviar a tu base de datos
    print("Registro Exitoso:");
    print("Usuario: $name, Email: $email, Avatar: $_selectedAvatarIndex");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("¡Cuenta creada correctamente!"),
        backgroundColor: DosifyColors.accentGreen,
      ),
    );

    // Navegar de regreso al Login tras un breve delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
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
              // Logo
              Image.asset(
                'assets/logo_dosify.png',
                height: 80,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.favorite, size: 80, color: DosifyColors.primaryTeal),
              ),
              const SizedBox(height: 20),
              
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
              const SizedBox(height: 40),

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

              // Inputs de Texto
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

              // Botón de Acción
              _buildPrimaryButton(
                text: "Finalizar Registro", 
                onPressed: _handleRegistration,
              ),

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
    final List<IconData> avatarIcons = [
      Icons.face_retouching_natural,
      Icons.face_unlock_outlined,
      Icons.face_6_outlined,
      Icons.face_5_outlined,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        bool isSelected = _selectedAvatarIndex == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedAvatarIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isSelected ? DosifyColors.primaryTeal.withOpacity(0.1) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? DosifyColors.accentGreen : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: isSelected ? 4 : 8,
                  offset: isSelected ? const Offset(0, 2) : const Offset(0, 4),
                  color: Colors.black.withOpacity(0.05),
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