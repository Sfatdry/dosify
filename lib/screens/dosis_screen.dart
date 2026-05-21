import 'package:flutter/material.dart';

class DosisScreen extends StatefulWidget {
  final String userName;

  const DosisScreen({super.key, required this.userName});

  @override
  State<DosisScreen> createState() => _DosisScreenState();
}

class _DosisScreenState extends State<DosisScreen> {
  // Estado seleccionado por defecto ('Pendiente')
  String _selectedEstado = 'Pendiente';
  
  // Controladores por si necesitas capturar los datos después
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();

  @override
  void dispose() {
    _fechaController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // ¡OJO! SIN AppBar aquí dentro para integrarse limpiamente con tu menú general
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
                      child: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "Registro de Dosis", 
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF006064)),
                    ),
                  ],
                ),
                const SizedBox(height: 35),

                // 2. CAMPO: FECHA PROGRAMADA
                const Text(
                  "Fecha Programada", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064), fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _fechaController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "dd/mm/aaaa",
                    prefixIcon: const Icon(Icons.calendar_today_outlined, color: primaryCyan, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF0F9FF),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _fechaController.text = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),

                // 3. CAMPO: HORA PROGRAMADA
                const Text(
                  "Hora Programada", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064), fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _horaController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "--:-- -----",
                    prefixIcon: const Icon(Icons.access_time, color: primaryCyan, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF0F9FF),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _horaController.text = pickedTime.format(context);
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),

                // 4. SECCIÓN: ESTADO (Selector Grid de 2x2)
                const Text(
                  "Estado", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064), fontSize: 14),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 2.5,
                  children: [
                    _buildEstadoButton("Pendiente", const Color(0xFFE0F2FE), const Color(0xFF0369A1)),
                    _buildEstadoButton("Tomada", const Color(0xFFDCFCE7), const Color(0xFF15803D)),
                    _buildEstadoButton("Omitida", const Color(0xFFFEE2E2), const Color(0xFFB91C1C)),
                    _buildEstadoButton("Tarde", const Color(0xFFFEF3C7), const Color(0xFFB45309)),
                  ],
                ),
                const SizedBox(height: 35),

                // 5. BOTÓN DE GUARDAR ACCIÓN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Acción para guardar en base de datos o lógica local
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Dosis marcada como: $_selectedEstado")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryCyan,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      "Guardar Estado", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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

  // Widget builder dinámico para los botones de estado interactivos
  Widget _buildEstadoButton(String estado, Color activeBgColor, Color activeTextColor) {
    bool isSelected = _selectedEstado == estado;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEstado = estado;
        });
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? activeTextColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Text(
          estado,
          style: TextStyle(
            color: isSelected ? activeTextColor : const Color(0xFF64748B),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}