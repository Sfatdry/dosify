import 'package:flutter/material.dart';

class RegistroMedicamentoScreen extends StatelessWidget {
  const RegistroMedicamentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Nuevo Recordatorio",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.add_task_rounded,
                size: 80,
                color: Color(0xFF5AB396),
              ),
            ),
            const SizedBox(height: 30),
            _cuteField(
              "Nombre del medicamento",
              "Ej: Aspirina",
              Icons.medication,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _cuteField("Dosis", "500mg", Icons.scale)),
                const SizedBox(width: 15),
                Expanded(
                  child: _cuteField("Frecuencia", "8 hrs", Icons.repeat),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _cuteField(
              "Instrucciones adicionales",
              "Tomar con agua...",
              Icons.info_outline,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B889C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  "Guardar Tratamiento",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cuteField(String label, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF5AB396)),
            filled: true,
            fillColor: const Color(0xFFF5F7F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
