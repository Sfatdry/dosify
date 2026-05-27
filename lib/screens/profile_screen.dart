import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key}); // Ya no pide parámetros obligatorios, ¡súper limpio!

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditingPassword = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  // Carga los datos reales del usuario logueado desde Supabase
  void _cargarDatosUsuario() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      _nameController.text = user.userMetadata?['full_name'] ?? "Usuario";
      _emailController.text = user.email ?? ""; // Muestra su correo real de registro
    } else {
      _nameController.text = "Usuario";
    }
  }

  // Actualiza la información del usuario en Supabase Auth
  Future<void> _guardarCambios() async {
    setState(() => _isLoading = true);
    try {
      // 1. Actualizar nombre completo en metadatos
      await supabase.auth.updateUser(
        UserAttributes(
          data: {'full_name': _nameController.text.trim()},
        ),
      );

      // 2. Si se activó la edición de contraseña y se escribió algo, se actualiza
      if (_isEditingPassword && _passwordController.text.isNotEmpty) {
        if (_passwordController.text.length < 8) {
          throw const AuthException("La contraseña debe tener mínimo 8 caracteres");
        }
        await supabase.auth.updateUser(
          UserAttributes(password: _passwordController.text.trim()),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Perfil actualizado con éxito!"), backgroundColor: Colors.green),
        );
        setState(() {
          _isEditingPassword = false;
          _passwordController.clear();
        });
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado de Perfil Estilizado
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryCyan,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Perfil de Usuario",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textCyan),
                    ),
                    Text(
                      "Administra tu información personal",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 40),

            // 1. Campo Nombre Completo
            const Text("Nombre completo", style: TextStyle(fontWeight: FontWeight.bold, color: textCyan, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: _inputStyle(Icons.person_outline, primaryCyan),
            ),
            const SizedBox(height: 25),

            // 2. Campo Correo Electrónico (Solo lectura por seguridad)
            const Text("Correo electrónico", style: TextStyle(fontWeight: FontWeight.bold, color: textCyan, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              enabled: false, 
              style: TextStyle(color: Colors.grey.shade700),
              decoration: _inputStyle(Icons.mail_outline, primaryCyan).copyWith(
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 25),

            // 3. Control Inteligente de Contraseña
            const Text("Contraseña", style: TextStyle(fontWeight: FontWeight.bold, color: textCyan, fontSize: 14)),
            const SizedBox(height: 8),
            
            if (!_isEditingPassword) ...[
              // Vista Normal: Oculta la clave y ofrece el botón de editar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: "••••••••••••"),
                      enabled: false,
                      decoration: _inputStyle(Icons.lock_outline, primaryCyan),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: () => setState(() => _isEditingPassword = true),
                    icon: const Icon(Icons.edit_rounded, color: primaryCyan, size: 18),
                    label: const Text("Editar", style: TextStyle(color: primaryCyan, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ] else ...[
              // Vista de Edición: Habilita el campo para escribir la nueva clave
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _inputStyle(
                      Icons.lock_outline, 
                      primaryCyan,
                      suffix: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ).copyWith(hintText: "Escribe tu nueva contraseña"),
                  ),
                  const SizedBox(height: 5),
                  TextButton(
                    onPressed: () => setState(() {
                      _isEditingPassword = false;
                      _passwordController.clear();
                    }),
                    child: const Text("Cancelar cambio", style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 40),

            // Botón Guardar Cambios
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _guardarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryCyan,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Guardar Cambios", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputStyle(IconData icon, Color primaryColor, {Widget? suffix}) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: primaryColor),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF0F9FA), 
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFB2EBF2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }
}