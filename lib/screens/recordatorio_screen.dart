import 'package:flutter/material.dart';

class RecordatorioScreen extends StatefulWidget {
  final String userName;

  const RecordatorioScreen({super.key, required this.userName});

  @override
  State<RecordatorioScreen> createState() => _RecordatorioScreenState();
}

class _RecordatorioScreenState extends State<RecordatorioScreen> {
  bool isCritica = false;
  bool isRecordatorioActivo = true;
  final TextEditingController _repeticionesController = TextEditingController();

  @override
  void dispose() {
    _repeticionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Ajustado al fondo global claro
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. ENCABEZADO
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryCyan,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_none, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "Recordatorio",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006064)),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // 2. SELECCIÓN DE TIPO DE ALERTA
                const Text(
                  "Tipo de Alerta",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildAlertOption("Normal", Icons.notifications_active_outlined, !isCritica)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildAlertOption("Crítica", Icons.error_outline, isCritica)),
                  ],
                ),
                const SizedBox(height: 25),

                // 3. CAMPO REPETICIONES
                const Text(
                  "Repeticiones",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _repeticionesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Número de repeticiones",
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    prefixIcon: const Icon(Icons.repeat, color: primaryCyan),
                    filled: true,
                    fillColor: const Color(0xFFF0F9FF),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 25),

                // 4. BANNER RECORDATORIO ACTIVO (SWITCH)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.notifications_none, color: primaryCyan),
                          SizedBox(width: 10),
                          Text(
                            "Recordatorio activo",
                            style: TextStyle(color: Color(0xFF0369A1), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Switch(
                        value: isRecordatorioActivo,
                        activeColor: primaryCyan,
                        onChanged: (val) => setState(() => isRecordatorioActivo = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                // 5. BOTÓN GUARDAR (AGREGADO Y CORREGIDO)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Recordatorio guardado con éxito")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryCyan,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      "Guardar Recordatorio",
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

  Widget _buildAlertOption(String label, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => isCritica = label == "Crítica"),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F7FA) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? const Color(0xFF00ACC1) : Colors.grey.shade300, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF00ACC1) : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? const Color(0xFF00ACC1) : Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}