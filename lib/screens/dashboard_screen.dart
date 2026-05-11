import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  // Añadimos esta variable para que el nombre no esté "pegado" al código
  final String userName;

  const DashboardScreen({
    super.key, 
    this.userName = "María" // Valor por defecto
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Dosify", 
          style: TextStyle(color: Color(0xFF2B889C), fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF5AB396).withOpacity(0.2),
              // Extraemos las iniciales del nombre dinámico
              child: Text(
                userName.substring(0, 1).toUpperCase() + (userName.contains(" ") ? userName.split(" ")[1][0] : ""), 
                style: const TextStyle(color: Color(0xFF2B889C), fontWeight: FontWeight.bold)
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aquí usamos la variable userName
            Text("¡Hola, $userName! 👋", 
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
            const Text("Tu salud está bajo control hoy", 
              style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 25),
            
            Row(
              children: [
                Expanded(child: _miniStatCard("Pendientes", "3", Icons.timer, Colors.orangeAccent)),
                const SizedBox(width: 15),
                Expanded(child: _miniStatCard("Tomadas", "12", Icons.check_circle, const Color(0xFF5AB396))),
              ],
            ),
            const SizedBox(height: 25),
            
            const Text("Próximas dosis", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B889C))),
            const SizedBox(height: 10),
            _doseTile("Amoxicilina", "08:00 AM", "500mg - Después de comer", Icons.medication),
            _doseTile("Losartán", "10:00 AM", "50mg - Ayunas", Icons.vaccines),
            _doseTile("Vitamina C", "01:00 PM", "1g - Tabletas", Icons.water_drop),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Tus widgets auxiliares se mantienen iguales para no romper tu diseño
  Widget _miniStatCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _doseTile(String name, String time, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: const Color(0xFF2B889C)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 13)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(time, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5AB396))),
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}