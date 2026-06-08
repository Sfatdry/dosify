import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_screen.dart';
import 'main_navigation.dart';
import '../widgets/neumorphic_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _snack("Por favor, ingresa correo y contraseña", Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ── PASO 1: Intentar con Supabase Auth (usuarios nuevos) ──
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null || response.user != null) {
        final nombre =
            response.user?.userMetadata?['full_name'] ??
            response.user?.email?.split('@')[0] ??
            'Usuario';
        final uId = response.user!.id;
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MainNavigation(userName: nombre, userId: uId),
            ),
          );
        }
        return;
      }
    } on AuthException catch (e) {
      debugPrint("Auth sign in error: ${e.message}");
    } catch (e) {
      debugPrint("General auth sign in error: $e");
    }

    try {
      // ── PASO 2: Buscar en tabla 'usuario' (usuarios legacy o casos especiales) ──
      final result = await Supabase.instance.client
          .from('usuario')
          .select()
          .eq('email', email)
          .eq('password', password)
          .maybeSingle();

      if (result == null) {
        if (mounted)
          _snack("Correo o contraseña incorrectos", Colors.redAccent);
        return;
      }

      final nombre = result['nombre'] ?? email.split('@')[0];
      final uId = result['id'].toString();

      // ── PASO 3: Navegación manual si Auth no generó sesión pero existe en la DB ──
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigation(userName: nombre, userId: uId),
          ),
        );
      }
    } catch (e) {
      if (mounted) _snack("Error: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    const Color tealColor = Color(0xFF00ACC1);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F9F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/dosify_logo_hd.PNG',
                  width: 150,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 150,
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),

              const Text(
                "Bienvenido",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006064),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Inicie sesión para continuar",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 40),

              // Input Email
              NeumorphicInput(
                hintText: "Correo electrónico",
                icon: Icons.email_outlined,
                controller: _emailController,
              ),
              const SizedBox(height: 20),

              // Input Contraseña
              NeumorphicInput(
                hintText: "Contraseña",
                icon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 40),

              // Botón Iniciar Sesión
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () =>
                            _handleLogin(), // 👈 REPARADO: Forzado de callback dinámico para Flutter Web
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tealColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Iniciar Sesión",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),

              // Enlace a Registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "¿No tienes cuenta? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    ),
                    child: const Text(
                      "Regístrate",
                      style: TextStyle(
                        color: tealColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
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
}
