import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final String userName;
  const DashboardScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // ¡OJO! SIN AppBar aquí dentro para evitar que se vea duplicado el logo y usuario
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Saludo personalizado con hora y fecha
            _buildHeader(userName),
            const SizedBox(height: 35),
            
            // 2. Tarjetas de Estadísticas Rápidas (Scroll Horizontal)
            const Text(
              "Resumen de hoy", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006064)),
            ),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _smallStatCard("Dosis Tomadas", "5 / 8", const Color(0xFFE0F2F1), const Color(0xFF004D40)),
                  const SizedBox(width: 15),
                  _smallStatCard("Medicamentos Activos", "3", const Color(0xFFE0F7FA), const Color(0xFF006064)),
                  const SizedBox(width: 15),
                  _smallStatCard("Alertas de Inventario", "1", const Color(0xFFFFEBEE), const Color(0xFFB71C1C)),
                ],
              ),
            ),
            const SizedBox(height: 35),

            // 3. Sección de Próximas Dosis
            _buildSectionCard(
              title: "Próximas Dosis",
              subtitle: "Horarios programados para el resto del día",
              icon: Icons.access_time_rounded,
              color: const Color(0xFF00ACC1),
              child: Column(
                children: [
                  _medRow("Paracetamol 500mg", "Tomar con agua después de comer", "14:00 PM", const Color(0xFF00ACC1)),
                  _medRow("Ibuprofeno 400mg", "Dosis de mantenimiento", "18:00 PM", const Color(0xFF00ACC1)),
                  _medRow("Vitamina C", "Suplemento diario", "21:00 PM", const Color(0xFF00ACC1)),
                ],
              ),
            ),
            const SizedBox(height: 35),

            // 4. Sección de Tratamientos Activos (Scroll Horizontal)
            _buildSectionCard(
              title: "Mis Tratamientos",
              subtitle: "Planes médicos en curso",
              icon: Icons.assignment_outlined,
              color: Colors.purple,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _treatmentCard("Tratamiento Gripal Corto", "01/05/2026", "07/05/2026"),
                    const SizedBox(width: 15),
                    _treatmentCard("Control de Presión Diario", "15/04/2026", "15/07/2026"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES INTERNOS DEL DASHBOARD ---

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("¡Hola, $name! 👋", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
            const SizedBox(height: 4),
            const Text("Tienes 3 dosis pendientes hoy", style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text("Sábado, 3 de Mayo", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
            SizedBox(height: 4),
            Text("13:15 PM", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00ACC1))),
          ],
        )
      ],
    );
  }

  Widget _smallStatCard(String label, String value, Color bgColor, Color textColor) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: textColor.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String subtitle, required IconData icon, required Color color, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1), 
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006064))), 
                  Text(subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _medRow(String name, String status, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.03), 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: color.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.medication_rounded, color: color, size: 22), 
              const SizedBox(width: 15), 
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064), fontSize: 14)), 
                  Text(status, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          Text(time, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _treatmentCard(String title, String start, String end) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)), 
            child: const Text("Activo", style: TextStyle(color: Color(0xFF15803D), fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF006064))),
          const SizedBox(height: 8),
          Text("Inicio: $start", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text("Fin: $end", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}