import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener intl en tu pubspec.yaml

class TratamientoScreen extends StatefulWidget {
  final String userName;

  const TratamientoScreen({super.key, required this.userName});

  @override
  State<TratamientoScreen> createState() => _TratamientoScreenState();
}

class _TratamientoScreenState extends State<TratamientoScreen> {
  // Controladores para las fechas
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();
  
  String _estadoSeleccionado = 'Activo'; // Estado inicial

  // Función para abrir el calendario
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
              primary: Color(0xFF00ACC1), // Color del calendario
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

  // Estilo de los campos (igual que en la imagen)
  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      suffixIcon: Icon(icon, color: const Color(0xFFE0F2F1), size: 20),
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
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Color(0xFF00ACC1),
            child: Icon(Icons.medication, color: Colors.white, size: 20),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Dosify", style: TextStyle(color: Color(0xFF006064), fontWeight: FontWeight.bold)),
            Text("Control inteligente de medicamentos", style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
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
            constraints: const BoxConstraints(maxWidth: 550),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
            ),
            child: Column(
              children: [
                // Icono superior
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00ACC1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.calendar_today, color: Colors.white, size: 35),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Tratamiento", 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF006064))
                ),
                const SizedBox(height: 30),

                // Campo Fecha Inicio
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Fecha de Inicio", style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF006064))),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _fechaInicioController,
                  readOnly: true,
                  onTap: () => _selectDate(context, _fechaInicioController),
                  decoration: _inputStyle("dd/mm/aaaa", Icons.calendar_month_outlined),
                ),

                const SizedBox(height: 25),

                // Campo Fecha Fin
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Fecha de Fin", style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF006064))),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _fechaFinController,
                  readOnly: true,
                  onTap: () => _selectDate(context, _fechaFinController),
                  decoration: _inputStyle("dd/mm/aaaa", Icons.calendar_month_outlined),
                ),

                const SizedBox(height: 25),

                // Selector de Estado
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Estado", style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF006064))),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _estadoSeleccionado,
                  decoration: _inputStyle("", Icons.info_outline),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF00ACC1)),
                  items: ['Activo', 'Finalizado', 'Pausado'].map((String val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val, style: const TextStyle(color: Color(0xFF006064))),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _estadoSeleccionado = val!),
                ),

                const SizedBox(height: 40),

                // Botón Guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Aquí agregarías la lógica para guardar en Supabase
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Tratamiento guardado exitosamente"))
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00ACC1),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text(
                      "Guardar Tratamiento", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
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