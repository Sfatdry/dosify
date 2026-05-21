import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Requiere 'flutter pub add intl' en tu terminal

class TratamientoScreen extends StatefulWidget {
  final String userName;
  const TratamientoScreen({super.key, required this.userName});

  @override
  State<TratamientoScreen> createState() => _TratamientoScreenState();
}

class _TratamientoScreenState extends State<TratamientoScreen> {
  // Controladores para el manejo real de fechas
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();
  
  String _estadoSeleccionado = 'Activo'; // Estado inicial

  // Función interactiva para abrir el calendario nativo
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00ACC1), // Color del calendario coincidente con Dosify
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

  // Estilo unificado para los inputs (borde celeste, fondo suave)
  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      suffixIcon: Icon(icon, color: const Color(0xFF00ACC1), size: 20),
      filled: true,
      fillColor: const Color(0xFFF0F9FF),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFBAE6FD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFBAE6FD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF00ACC1), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Fondo limpio grisáceo
      // ¡OJO! No hay AppBar aquí para que NO se duplique el header de Dosify
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04), 
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono superior centrado de Tratamiento
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00ACC1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Tratamiento", 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF006064))
                ),
                const SizedBox(height: 32),

                // Campo Fecha Inicio
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text("Fecha de Inicio", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF006064), fontSize: 14)),
                  ),
                ),
                TextField(
                  controller: _fechaInicioController,
                  readOnly: true,
                  onTap: () => _selectDate(context, _fechaInicioController),
                  decoration: _inputStyle("dd/mm/aaaa", Icons.calendar_month_outlined),
                ),

                const SizedBox(height: 24),

                // Campo Fecha Fin
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text("Fecha de Fin", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF006064), fontSize: 14)),
                  ),
                ),
                TextField(
                  controller: _fechaFinController,
                  readOnly: true,
                  onTap: () => _selectDate(context, _fechaFinController),
                  decoration: _inputStyle("dd/mm/aaaa", Icons.calendar_month_outlined),
                ),

                const SizedBox(height: 24),

                // Selector de Estado
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text("Estado", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF006064), fontSize: 14)),
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _estadoSeleccionado,
                  style: const TextStyle(color: Color(0xFF006064), fontSize: 15),
                  decoration: _inputStyle("", Icons.info_outline_rounded),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF00ACC1)),
                  items: ['Activo', 'Finalizado', 'Pausado'].map((String val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val, style: const TextStyle(color: Color(0xFF006064))),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _estadoSeleccionado = val!),
                ),

                const SizedBox(height: 35),

                // Botón Guardar (Estilo pill redondeado)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Tratamiento guardado exitosamente"))
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00ACC1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      "Guardar Tratamiento", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
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
}