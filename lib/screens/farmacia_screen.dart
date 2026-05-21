import 'package:flutter/material.dart';

class FarmaciaScreen extends StatefulWidget {
  final String userName;

  const FarmaciaScreen({super.key, required this.userName});

  @override
  State<FarmaciaScreen> createState() => _FarmaciaScreenState();
}

class _FarmaciaScreenState extends State<FarmaciaScreen> {
  // Controladores para capturar los datos ingresados
  final TextEditingController _nombreFarmaciaController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _latitudController = TextEditingController();
  final TextEditingController _longitudController = TextEditingController();

  @override
  void dispose() {
    _nombreFarmaciaController.dispose();
    _ubicacionController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
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
            constraints: const BoxConstraints(maxWidth: 500),
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
                // 1. ENCABEZADO DE LA TARJETA
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryCyan,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.local_pharmacy_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "Farmacia",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006064),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),

                // 2. CAMPO: NOMBRE
                _buildLabel("Nombre"),
                TextField(
                  controller: _nombreFarmaciaController,
                  decoration: _inputStyle("Nombre de la farmacia", Icons.location_on_outlined),
                ),
                const SizedBox(height: 25),

                // 3. CAMPO: UBICACIÓN
                _buildLabel("Ubicación"),
                TextField(
                  controller: _ubicacionController,
                  decoration: _inputStyle("Dirección completa", Icons.near_me_outlined),
                ),
                const SizedBox(height: 25),

                // 4. FILA COMPARTIDA: LATITUD Y LONGITUD
                Row(
                  children: [
                    // Columna Latitud
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Latitud"),
                          TextField(
                            controller: _latitudController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _inputStyle("-12.0464", null),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Columna Longitud
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Longitud"),
                          TextField(
                            controller: _longitudController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _inputStyle("-77.0428", null),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),

                // 5. BOTÓN DE GUARDAR FARMACIA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Simulación de guardado de datos
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Farmacia '${_nombreFarmaciaController.text.isNotEmpty ? _nombreFarmaciaController.text : "Nueva"}' registrada con éxito"),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryCyan,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      "Guardar Farmacia",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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

  // --- COMPONENTES AUXILIARES DE ESTILO ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF006064),
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String hint, IconData? prefixIcon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF00ACC1), size: 20) : null,
      filled: true,
      fillColor: const Color(0xFFF0F9FF), // Tono celeste suave exacto de tus capturas
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFBAE6FD), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFBAE6FD), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF00ACC1), width: 1.5),
      ),
    );
  }
}