import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _generoSeleccionado = 0; // 0: Mujer, 1: Hombre, 2: No Binario
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);
    const Color textCyan = Color(0xFF006064);

    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco como solicitaste
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
        child: Column(
          children: [
            // 1. EL LOGO (Usa la imagen de alta calidad)
            Center(
              child: Image.asset(
                'assets/images/dosify_logo_hd.png', // Asegúrate de agregar la imagen en assets
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

            // 3. SELECCIÓN DE GÉNERO (Solo 3 iconos grandes)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGenderIcon(0, Icons.face_3, "Mujer", primaryCyan),
                _buildGenderIcon(1, Icons.face, "Hombre", primaryCyan),
                _buildGenderIcon(2, Icons.face_5, "No Binario", primaryCyan),
              ],
            ),
            const SizedBox(height: 40),

            // 4. CAMPOS DE TEXTO
            _buildTextField("Nombre Completo", Icons.person_outline, primaryCyan),
            const SizedBox(height: 15),
            _buildTextField("Correo Electrónico", Icons.mail_outline, primaryCyan, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 15),
            _buildTextField(
              "Contraseña",
              Icons.lock_outline,
              primaryCyan,
              obscure: _obscurePassword,
              suffix: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 50),

            // 5. BOTÓN DE REGISTRO
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryCyan,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text(
                  "Finalizar Registro",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET AUXILIAR PARA ICONOS DE GÉNERO ---
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

  // --- WIDGET AUXILIAR PARA CAMPOS DE TEXTO ESTILIZADOS ---
  Widget _buildTextField(String label, IconData icon, Color primaryColor, {bool obscure = false, Widget? suffix, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: primaryColor),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF8FAFC), // Un gris ultra claro para contraste
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}