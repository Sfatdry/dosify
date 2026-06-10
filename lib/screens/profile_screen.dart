import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Instancia oficial de tu cliente de Supabase
  final SupabaseClient supabase = Supabase.instance.client;

  // Controladores para colocar los datos en las cajitas de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _userId; // Guardará el ID del usuario actual

  @override
  void initState() {
    super.initState(); // <-- CORREGIDO: Ya no hay llaves raras aquí
    _cargarDatosDelUsuario(); // Carga la información automáticamente al abrir la pantalla
  }

  // FUNCIÓN PARA CONSULTAR SUPABASE: Trae la última fila registrada
  Future<void> _cargarDatosDelUsuario() async {
    try {
      // Hacemos un SELECT a la tabla 'usuario'.
      final List<dynamic> response = await supabase
          .from('usuario')
          .select()
          .eq('id', widget.userId)
          .limit(1);

      if (response.isNotEmpty) {
        final usuario = response.first;

        // Guardamos los datos locales
        _userId = usuario['id'];

        // Colocamos el texto real dentro de tus inputs estéticos
        _nameController.text = usuario['nombre'] ?? '';
        _emailController.text = usuario['email'] ?? '';
        _passwordController.text = usuario['password'] ?? '';
      } else {
        // Datos de respaldo por si la tabla llegara a estar vacía
        _nameController.text = "Sin nombre";
        _emailController.text = "sin_correo@gmail.com";
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al cargar perfil: $error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // FUNCIÓN PARA ACTUALIZAR: Por si el usuario edita su nombre o clave y le da a "Guardar Cambios"
  Future<void> _actualizarPerfil() async {
    if (_userId == null) return;

    setState(() => _isSaving = true);

    try {
      await supabase
          .from('usuario')
          .update({
            'nombre': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text.trim(),
          })
          .eq('id', _userId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Perfil actualizado correctamente!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar cambios: $error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryCyan))
          : Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 550),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado idéntico a tu interfaz actual
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: primaryCyan,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Perfil de Usuario",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: textCyan,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Administra tu información personal",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Label: Nombre completo
                      const Text(
                        "Nombre completo",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textCyan,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _nameController,
                        icon: Icons.person_outline_rounded,
                        primaryColor: primaryCyan,
                      ),
                      const SizedBox(height: 25),

                      // Label: Correo electrónico
                      const Text(
                        "Correo electrónico",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textCyan,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _emailController,
                        icon: Icons.mail_outline_rounded,
                        primaryColor: primaryCyan,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 25),

                      // Label: Contraseña
                      const Text(
                        "Contraseña",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textCyan,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _passwordController,
                        icon: Icons.lock_outline_rounded,
                        primaryColor: primaryCyan,
                        obscureText: true,
                      ),
                      const SizedBox(height: 45),

                      // --- BOTÓN PRINCIPAL DE GUARDAR CAMBIOS ---
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _actualizarPerfil,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryCyan,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Guardar Cambios",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // --- BOTÓN CERRAR SESIÓN ---
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          onPressed: () async {
                            await supabase.auth.signOut();
                            if (mounted) {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Cerrar Sesión",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Estructura visual exacta de tus inputs redondeados con fondo grisáceo suave
  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required Color primaryColor,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryColor, size: 22),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
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
