import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final String userName; // Aquí recibiremos el nombre real

  // El constructor ahora pide el userName de forma obligatoria
  const DashboardScreen({super.key, required this.userName}); 

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);
   

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(primaryCyan, userName),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. BIENVENIDA (Imagen 1)
                _buildHeader(userName),
                const SizedBox(height: 30),
                
                // Resumen de dosis (Tarjetas pequeñas)
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _smallStatCard("Tratamientos activos", "3", Colors.blue.shade50, Colors.blue),
                    _smallStatCard("Dosis tomadas hoy", "3", Colors.green.shade50, Colors.green),
                    _smallStatCard("Dosis pendientes", "3", Colors.orange.shade50, Colors.orange),
                  ],
                ),
                const SizedBox(height: 40),

                // 2. PRÓXIMAS DOSIS (Imagen 2)
                _buildSectionCard(
                  title: "Próximas dosis",
                  subtitle: "Programadas para hoy",
                  icon: Icons.access_time,
                  color: Colors.cyan,
                  child: Column(
                    children: [
                      _medRow("Amoxicilina", "Pendiente", "14:00", Colors.cyan),
                      _medRow("Losartán", "Pendiente", "18:00", Colors.cyan),
                      _medRow("Metformina", "Pendiente", "20:00", Colors.cyan),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // 3. TRATAMIENTOS ACTIVOS (Imagen 3)
                _buildSectionCard(
                  title: "Tratamientos activos",
                  subtitle: "En curso",
                  icon: Icons.assignment_outlined,
                  color: Colors.purple,
                  child: Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: [
                      _treatmentCard("Infección Respiratoria", "2026-04-28", "2026-05-05"),
                      _treatmentCard("Hipertensión", "2026-04-01", "2026-05-01"),
                      _treatmentCard("Diabetes", "2026-04-01", "2026-05-01"),
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

  // --- COMPONENTES DEL DASHBOARD ---

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("¡Hola, $name! 👋", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
            const Text("Tienes 3 dosis pendientes hoy", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text("Sábado, 3 de Mayo", style: TextStyle(color: Colors.grey)),
            Text("13:15 PM", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF00ACC1))),
          ],
        )
      ],
    );
  }

  Widget _smallStatCard(String label, String value, Color bgColor, Color textColor) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: textColor.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String subtitle, required IconData icon, required Color color, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
              const SizedBox(width: 15),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(subtitle, style: const TextStyle(color: Colors.grey))]),
            ],
          ),
          const SizedBox(height: 25),
          child,
        ],
      ),
    );
  }

  Widget _medRow(String name, String status, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withOpacity(0.1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Icon(Icons.medication, color: color), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(status, style: const TextStyle(fontSize: 12, color: Colors.grey))])]),
          Text(time, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _treatmentCard(String title, String start, String end) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.purple.shade50), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)), child: const Text("activo", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold))),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          Text("Inicio: $start", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text("Fin: $end", style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color cyan, String name) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(padding: const EdgeInsets.all(8.0), child: CircleAvatar(backgroundColor: cyan, child: const Icon(Icons.medication, color: Colors.white))),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("Dosify", style: TextStyle(color: Color(0xFF006064), fontWeight: FontWeight.bold)), Text("Control inteligente", style: TextStyle(fontSize: 12, color: Colors.grey))]),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(children: [
            Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [const Text("Bienvenida", style: TextStyle(fontSize: 10, color: Colors.grey)), Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF006064)))]),
            const SizedBox(width: 12),
            CircleAvatar(backgroundColor: const Color(0xFF00C853), child: Text(name.substring(0, 1), style: const TextStyle(color: Colors.white))),
          ]),
        )
      ],
    );
  }
}