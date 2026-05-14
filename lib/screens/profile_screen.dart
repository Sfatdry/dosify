import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;

  const ProfileScreen({super.key, required this.userName});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = Supabase.instance.client.auth.currentUser;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: user?.email ?? "usuario@email.com");
    _passwordController = TextEditingController(text: "********");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF00ACC1), size: 20),
      filled: true,
      fillColor: const Color(0xFFF0F9FF),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFBAE6FD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFBAE6FD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF00ACC1), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String initial = widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : "?";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Dosify", style: TextStyle(color: Color(0xFF006064), fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                crossAxisAlignment: CrossAxisAlignment.end, 
                children: [
                  const Text("Bienvenida", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(widget.userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF006064)))
                ]
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: const Color(0xFF00C853), 
                child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 12))
              ),
            ]),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Tarjeta de Estadística
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Tratamientos activos", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          SizedBox(height: 5),
                          Text("3", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
                        ],
                      ),
                      const Icon(Icons.show_chart, size: 40, color: Color(0xFF00ACC1)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 2. Encabezado "Perfil de Usuario"
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00ACC1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 35),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Perfil de Usuario", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
                        Text("Administra tu información personal", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 30),

                // 3. Formulario (Campos de texto)
                const Text("Nombre completo", style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF006064))),
                const SizedBox(height: 8),
                TextField(controller: _nameController, decoration: _inputStyle("Nombre", Icons.person_outline)),
                
                const SizedBox(height: 20),
                const Text("Correo electrónico", style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF006064))),
                const SizedBox(height: 8),
                TextField(controller: _emailController, decoration: _inputStyle("Email", Icons.mail_outline)),
                
                const SizedBox(height: 20),
                const Text("Contraseña", style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF006064))),
                const SizedBox(height: 8),
                TextField(controller: _passwordController, obscureText: true, decoration: _inputStyle("Password", Icons.lock_outline)),

                const SizedBox(height: 40),

                // 4. Botones de acción
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cambios guardados")));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00ACC1),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text("Guardar Cambios", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                           Navigator.pop(context); // O la acción que prefieras para cancelar
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: TextButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text("Cerrar Sesión", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}