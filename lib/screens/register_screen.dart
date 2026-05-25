import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar el texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _generoSeleccionado = 0; // 0: Mujer, 1: Hombre, 2: No Binario
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Mapa para traducir el índice a texto para la base de datos
  final List<String> _generos = ["Mujer", "Hombre", "No Binario"];

  // FUNCIÓN PARA REGISTRAR EN SUPABASE
  Future<void> _registrarUsuario() async {
    // Si las validaciones del formulario fallan (contraseña corta, etc), no hace nada
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Registramos en Supabase Auth
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'full_name': _nameController.text.trim(),
          'gender': _generos[_generoSeleccionado],
        },
      );

      if (res.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("¡Registro exitoso! Ya puedes iniciar sesión."),
              backgroundColor: Colors.green,
            ),
          );
          // Regresa al Login automáticamente
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
          SnackBar(content: Text("Error inesperado: $error"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // VALIDACIÓN DE CONTRASEÑA PREMIUM (Mínimo 8 caracteres, letras, números y símbolos)
  String? _validarPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Por favor, escribe una contraseña";
    }
    if (value.length < 8) {
      return "La contraseña debe tener mínimo 8 caracteres";
    }
    
    // Expresión regular para obligar: letras, números y caracteres especiales (como _ o ?)
   final regexSimbolos = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&_#./\-+])[A-Za-z\d@$!%*?&_#./\-+]{8,}$');
if (!regexSimbolos.hasMatch(value)) {
  return "Debe incluir letras, números y caracteres especiales (ej: abc_?2673)";
}
    
    return null; // Todo bien
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
        leading: const BackButton(color: Color(0xFF94A3B8)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(color: Color(0xFFE2E8F0), shape: BoxShape.circle),
              child: const Icon(Icons.person_add_alt_1_rounded, color: primaryCyan, size: 18),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey, // Envolvemos todo en un Form
          child: Column(
            children: [
              // 1. EL LOGO
              Center(
                child: Image.asset(
                  'assets/dosify_logo_hd.PNG', 
                  height: 120,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "RECORDATORIOS DE MEDICACIÓN",
                style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // 2. TÍTULO Y SUBTÍTULO
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Crear Cuenta",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textCyan),
                ),
              ),
              const SizedBox(height: 5),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Únase a la red de cuidado Dosify",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 40),

              // 3. SELECCIÓN DE GÉNERO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGenderIcon(0, Icons.face_3, "Mujer", primaryCyan),
                  _buildGenderIcon(1, Icons.face, "Hombre", primaryCyan),
                  _buildGenderIcon(2, Icons.face_5, "No Binario", primaryCyan),
                ],
              ),
              const SizedBox(height: 40),

              // 4. CAMPOS DE TEXTO CON VALIDACIONES
              TextFormField(
                controller: _nameController,
                validator: (val) => val == null || val.isEmpty ? "Escribe tu nombre" : null,
                decoration: _inputStyle("Nombre Completo", Icons.person_outline, primaryCyan),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val == null || !val.contains('@') ? "Ingresa un correo válido" : null,
                decoration: _inputStyle("Correo Electrónico", Icons.mail_outline, primaryCyan),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: _validarPassword, // Aplica la regla estricta de 8 caracteres y símbolos
                decoration: _inputStyle(
                  "Contraseña",
                  Icons.lock_outline,
                  primaryCyan,
                  suffix: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // 5. BOTÓN DE REGISTRO CON SPINNER DE CARGA
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registrarUsuario, // Llama a la base de datos
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryCyan,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text(
                          "Finalizar Registro",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderIcon(int index, IconData icon, String label, Color primaryColor) {
    bool isSelected = _generoSeleccionado == index;
    return GestureDetector(
      onTap: () => setState(() => _generoSeleccionado = index),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade300, width: isSelected ? 2 : 1),
            ),
            child: Icon(icon, size: 35, color: isSelected ? primaryColor : Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? primaryColor : Colors.grey),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon, Color primaryColor, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: primaryColor),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500), // Estilo del error en rojo
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1), // Borde rojo si falla
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
}