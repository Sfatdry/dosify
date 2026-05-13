import 'package:flutter/material.dart';

class HistorialScreen extends StatelessWidget {
  final String userName; // Recibimos el nombre dinámico

  const HistorialScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    // Obtenemos la inicial del nombre para el círculo (Ej: "Juan" -> "J")
    String initial = userName.isNotEmpty ? userName[0].toUpperCase() : "?";

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
            Text("Control inteligente de medicamentos", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Bienvenida", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    // AQUÍ USAMOS EL NOMBRE REAL
                    Text(
                      userName, 
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF006064))
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: const Color(0xFF00C853),
                  // AQUÍ USAMOS LA INICIAL REAL
                  child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildMainCard(),
            const SizedBox(height: 20),
            _buildTotalDosisCard(),
            const SizedBox(height: 20),
            _buildFooterMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Historial de Cumplimiento", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Seguimiento del tratamiento", style: TextStyle(color: Colors.grey)),
                ],
              ),
              Column(
                children: const [
                  Text("94%", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00ACC1))),
                  Text("Adherencia", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              )
            ],
          ),
          const SizedBox(height: 25),
          const Text("Porcentaje de adherencia", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.94,
              minHeight: 12,
              backgroundColor: Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              _buildStatBox("Dosis Tomadas", "40", const Color(0xFFE8F5E9), const Color(0xFF00C853), Icons.check_circle),
              const SizedBox(width: 10),
              _buildStatBox("Dosis Omitidas", "1", const Color(0xFFFFEBEE), const Color(0xFFE91E63), Icons.cancel),
              const SizedBox(width: 10),
              _buildStatBox("Dosis Tardías", "2", const Color(0xFFFFF8E1), const Color(0xFFFFB300), Icons.access_time_filled),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String count, Color bgColor, Color iconColor, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: bgColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 30),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 10, color: iconColor, fontWeight: FontWeight.bold)),
            Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalDosisCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("Total de dosis en el tratamiento", style: TextStyle(color: Color(0xFF0369A1), fontWeight: FontWeight.w500)),
          Text("43", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
        ],
      ),
    );
  }

  Widget _buildFooterMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00ACC1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Text(
          "¡Excelente progreso!", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
        ),
      ),
    );
  }
}