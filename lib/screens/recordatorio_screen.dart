import 'package:flutter/material.dart';

class RecordatorioScreen extends StatefulWidget {
  final String userName; // <--- AGREGADO

  const RecordatorioScreen({super.key, required this.userName}); // <--- CORREGIDO

  @override
  State<RecordatorioScreen> createState() => _RecordatorioScreenState();
}

class _RecordatorioScreenState extends State<RecordatorioScreen> {
  bool isCritica = false;
  bool isRecordatorioActivo = true;

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Dosify", style: TextStyle(color: Color(0xFF006064), fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Bienvenida", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(widget.userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF006064))), // <--- CORREGIDO
                  ],
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: const Color(0xFF00C853),
                  child: Text(widget.userName[0].toUpperCase(), style: const TextStyle(color: Colors.white)), // <--- INICIAL DINÁMICA
                ),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: primaryCyan, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.notifications_none, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    const Text("Recordatorio", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
                  ],
                ),
                const SizedBox(height: 30),
                const Text("Tipo de Alerta", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildAlertOption("Normal", Icons.notifications_active_outlined, !isCritica)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildAlertOption("Crítica", Icons.error_outline, isCritica)),
                  ],
                ),
                const SizedBox(height: 25),
                const Text("Repeticiones", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064))),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Número de repeticiones",
                    prefixIcon: const Icon(Icons.repeat, color: primaryCyan),
                    filled: true,
                    fillColor: const Color(0xFFF0F9FF),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 25),
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
                      const Row(
                        children: [
                          Icon(Icons.notifications_none, color: primaryCyan),
                          SizedBox(width: 10),
                          Text("Recordatorio activo", style: TextStyle(color: Color(0xFF0369A1), fontWeight: FontWeight.w500)),
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