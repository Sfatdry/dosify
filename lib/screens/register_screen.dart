import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// NOTA: Asegúrate de que el nombre de tu clase coincida con tu archivo original
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Controladores de texto para los campos de tu pantalla
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String _selectedGender = "Mujer"; // Género por defecto de los círculos de tu diseño

  Future<void> _registrarUsuario() async {
    // Validaciones básicas antes de enviar
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
      // PASO 1: Crear el usuario en el sistema de Autenticación de Supabase (auth.users)
      final AuthResponse response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        // Guardamos también el nombre en los metadatos internos por seguridad
        data: {
          'full_name': _nameController.text.trim(),
          'gender': _selectedGender,
        },
      );

      final String? userId = response.user?.id;

      if (userId != null) {
        // PASO 2: ¡EL PASO FALTANTE! Guardar los datos en tu tabla pública 'usuario'
        // Mapeando las columnas exactas que vi en tu captura de Supabase: id, nombre, email, password
        await supabase.from('usuario').insert({
          'id': userId, // Vincula el mismo ID único de autenticación
          'nombre': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(), // Se guarda el texto (o encriptado si lo prefieres)
          'fecha_registro': DateTime.now().toIso8601String(), // Llena tu columna de timestamp
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("¡Cuenta creada y guardada con éxito!"), backgroundColor: Colors.green),
          );
          
          // Aquí puedes redirigir a tu MainNavigation mandando el nombre:
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainNavigation(userName: _nameController.text.trim())));
        }
      }

    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error de autenticación: ${error.message}"), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar en base de datos: $error"), backgroundColor: Colors.red),
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
    // Aquí va todo tu hermoso diseño con los inputs y el botón "Finalizar Registro"
    // Solo asegúrate de ponerle al botón elevado o GestureDetector lo siguiente:
    // onPressed: _isLoading ? null : _registrarUsuario
    return Scaffold(
      body: Center(child: Text("Integra este método _registrarUsuario en tu botón")),
    );
  }
}