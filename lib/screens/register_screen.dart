import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Controladores para capturar los textos
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedGender = "Mujer"; // Maneja la selección de tus círculos

  // Función principal que guarda la información en ambos lados de Supabase
  Future<void> _registrarUsuario() async {
    if (_nameController.text.trim().isEmpty || 
        _emailController.text.trim().isEmpty || 
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, llena todos los campos"), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La contraseña debe tener al menos 6 caracteres"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Crear el usuario en la sección interna de Autenticación de Supabase (auth.users)
      final AuthResponse response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'full_name': _nameController.text.trim(),
          'gender': _selectedGender,
        },
      );

      final String? userId = response.user?.id;

      if (userId != null) {
        // 2. ¡Doble guardado! Insertar los datos en tu tabla pública 'usuario'
        await supabase.from('usuario').insert({
          'id': userId, // Vincula el mismo ID único de autenticación
          'nombre': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(), // Guarda la contraseña en texto plano en tu tabla
          'fecha_registro': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("¡Cuenta creada y guardada con éxito!"), backgroundColor: Colors.green),
          );
          
          // Al terminar con éxito, te regresa a la pantalla anterior o login
          Navigator.pop(context);
        }
      }

    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error en la base de datos: $error"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);
    const Color textCyan = Color(0xFF006064);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: primaryCyan),
            onPressed: () {},
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtítulo superior centralizado (Solución temporal al logo ausente)
            const Center(
              child: Text(
                "RECORDATORIOS DE MEDICACIÓN",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 30),

            // Títulos Principales
            const Text(
              "Crear Cuenta",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textCyan),
            ),
            const SizedBox(height: 5),
            Text(
              "Únase a la red de cuidado Dosify",
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 40),

            // --- SELECTOR DE GÉNERO (Tus tres círculos del diseño) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGenderOption("Mujer", Icons.face_retouching_natural_rounded, primaryCyan),
                const SizedBox(width: 40),
                _buildGenderOption("Hombre", Icons.face_rounded, primaryCyan),
                const SizedBox(width: 40),
                _buildGenderOption("No Binario", Icons.child_care_rounded, primaryCyan),
              ],
            ),
            const SizedBox(height: 40),

            // Campo: Nombre Completo
            _buildInputField(
              controller: _nameController,
              hintText: "Nombre Completo",
              icon: Icons.person_outline_rounded,
              primaryColor: primaryCyan,
            ),
            const SizedBox(height: 20),

            // Campo: Correo Electrónico
            _buildInputField(
              controller: _emailController,
              hintText: "Correo Electrónico",
              icon: Icons.mail_outline_rounded,
              primaryColor: primaryCyan,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Campo: Contraseña
            _buildInputField(
              controller: _passwordController,
              hintText: "Contraseña",
              icon: Icons.lock_outline_rounded,
              primaryColor: primaryCyan,
              obscureText: _obscurePassword,
              suffix: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 50),

            // Botón de Registrarse
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registrarUsuario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryCyan,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Finalizar Registro",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para tus círculos interactivos de género
  Widget _buildGenderOption(String gender, IconData icon, Color activeColor) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF8FAFC),
              border: Border.all(
                color: isSelected ? activeColor : Colors.grey.shade300,
                width: isSelected ? 2.5 : 1.0,
              ),
            ),
            child: Icon(
              icon,
              size: 35,
              color: isSelected ? activeColor : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            gender,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? activeColor : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para estilizar tus campos de texto con bordes suaves
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color primaryColor,
    bool obscureText = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
        prefixIcon: Icon(icon, color: primaryColor, size: 22),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}