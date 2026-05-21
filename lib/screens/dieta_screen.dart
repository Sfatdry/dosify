import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Recuerda ejecutar 'flutter pub add intl'

class DietaScreen extends StatefulWidget {
  final String userName;

  const DietaScreen({super.key, required this.userName});

  @override
  State<DietaScreen> createState() => _DietaScreenState();
}

class _DietaScreenState extends State<DietaScreen> {
  // Controladores para los campos
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();

  // Función para abrir el calendario
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00ACC1), // Color Dosify
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. ENCABEZADO: ICONO Y TÍTULO
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryCyan,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "Dieta",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006064),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),

                // 2. CAMPO: DESCRIPCIÓN (MULTILÍNEA)
                _buildLabel("Descripción"),
                TextField(
                  controller: _descripcionController,
                  maxLines: 5,
                  decoration: _inputStyle(
                    "Describe la dieta recomendada...",
                    null,
                  ),
                ),
                const SizedBox(height: 25),

                // 3. CAMPO: FECHA DE INICIO
                _buildLabel("Fecha de Inicio"),
                TextField(
                  controller: _fechaInicioController,
                  readOnly: true,
                  onTap: () => _selectDate(context, _fechaInicioController),
                  decoration: _inputStyle("dd/mm/aaaa", Icons.calendar_today_outlined),
                ),
                const SizedBox(height: 25),

                // 4. CAMPO: FECHA DE FIN
                _buildLabel("Fecha de Fin"),
                TextField(
                  controller: _fechaFinController,
                  readOnly: true,
                  onTap: () => _selectDate(context, _fechaFinController),
                  decoration: _inputStyle("dd/mm/aaaa", Icons.calendar_today_outlined),
                ),
                const SizedBox(height: 40),

                // 5. BOTÓN GUARDAR
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Dieta guardada exitosamente")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryCyan,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      "Guardar Dieta",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA MANTENER EL CÓDIGO LIMPIO ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF006064),
          fontSize: 15,
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      suffixIcon: icon != null ? Icon(icon, color: const Color(0xFFBAE6FD), size: 20) : null,
      filled: true,
      fillColor: const Color(0xFFF0F9FF), // Fondo celeste suave de tu captura
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
        borderSide: const BorderSide(color: Color(0xFF00ACC1), width: 1.5),
      ),
    );
  }
}