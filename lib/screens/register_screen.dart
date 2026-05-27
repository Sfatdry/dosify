import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart'; // <-- Importación necesaria para el formato UUID

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Instancia oficial de tu cliente de Supabase
  final SupabaseClient supabase = Supabase.instance.client;

  // Instancia del generador de UUID
  final Uuid _uuidGenerator = const Uuid();

  // Controladores para capturar lo que escribes en la pantalla
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedGender = "Mujer"; // Controla cuál círculo está seleccionado

  // FUNCIÓN PRINCIPAL: Guarda directo en tu tabla 'usuario' sin bloqueos de email
  Future<void> _registrarUsuarioDirecto() async {
    // 1. Validar que ningún campo se quede vacío
    if (_nameController.text.trim().isEmpty || 
        _emailController.text.trim().isEmpty || 
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, llena todos los campos"), 
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // CORRECCIÓN AQUÍ: Generamos un UUID v4 real que Supabase acepta perfectamente
      final String secureUuid = _uuidGenerator.v4();

      // 2. Insertar los datos directamente en las columnas de tu tabla en Supabase
      await supabase.from('usuario').insert({
        'id': secureUuid, // <-- Ya no es un número, ahora es un UUID válido de 36 caracteres
        'nombre': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(), // Guarda la contraseña directo
        'fecha_registro': DateTime.now().toIso8601String(), // Llena el timestamp actual
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Usuario registrado con éxito en Dosify!"), 
            backgroundColor: Colors.green,
          ),
        );
        
        // Cierra la pantalla de registro y te regresa al Login o pantalla anterior
        Navigator.pop(context);
      }

    } catch (error) {
      // Si pasa un error con la base de datos, te avisará aquí
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar en Supabase: $error"), 
            backgroundColor: Colors.red,
          ),
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
    // Paleta de colores Cyan Premium de tu diseño original
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "RECORDATORIOS DE MEDICACIÓN",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 30),

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

            // --- FILA DE SELECCIÓN DE GÉNERO (Tus 3 círculos interactivos) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGenderCircle("Mujer", Icons.face_retouching_natural_rounded, primaryCyan),
                const SizedBox(width: 35),
                _buildGenderCircle("Hombre", Icons.face_rounded, primaryCyan),
                const SizedBox(width: 35),
                _buildGenderCircle("No Binario", Icons.child_care_rounded, primaryCyan),
              ],
            ),
            const SizedBox(height: 40),

            // Campo de texto: Nombre Completo
            _buildTextField(
              controller: _nameController,
              hintText: "Nombre Completo",
              icon: Icons.person_outline_rounded,
              primaryColor: primaryCyan,
            ),
            const SizedBox(height: 20),

            // Campo de texto: Correo Electrónico
            _buildTextField(
              controller: _emailController,
              hintText: "Correo Electrónico",
              icon: Icons.mail_outline_rounded,
              primaryColor: primaryCyan,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Campo de texto: Contraseña con ojito para ocultar/mostrar
            _buildTextField(
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
            const SizedBox(height: 45),

            // --- BOTÓN PRINCIPAL DE REGISTRO ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registrarUsuarioDirecto,
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

  // Creador estético de los círculos de género
  Widget _buildGenderCircle(String gender, IconData icon, Color activeColor) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
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
              size: 32,
              color: isSelected ? activeColor : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            gender,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? activeColor : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // Creador estético de los inputs con bordes redondeados y fondo suave
  Widget _buildTextField({
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
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
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