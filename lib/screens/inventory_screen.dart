import 'package:flutter/material.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(primaryCyan),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. FILA DE MEDICAMENTOS (Scroll Horizontal)
            const Text("Medicamentos en uso", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMedCard("Amoxicilina", "21 / 30", 0.7, "7 días", "10 unidades", Colors.teal, false),
                  const SizedBox(width: 15),
                  _buildMedCard("Losartán", "8 / 30", 0.26, "8 días", "10 unidades", Colors.pink, true),
                  const SizedBox(width: 15),
                  _buildMedCard("Metformina", "28 / 60", 0.46, "14 días", "15 unidades", Colors.orange, false),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 2. RESUMEN DE INVENTARIO (Contadores por color)
            _buildResumenSeccion(primaryCyan),
            const SizedBox(height: 30),

            // 3. REABASTECIMIENTO (Sección inferior)
            _buildReabastecimientoSeccion(),
          ],
        ),
      ),
    );
  }

  // --- BLOQUE 1: TARJETAS DE MEDICAMENTOS ---
  Widget _buildMedCard(String name, String stock, double progress, String duration, String alertMin, Color color, bool hasAlert) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: hasAlert ? Colors.orangeAccent : Colors.transparent, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(Icons.medication_outlined, color: color)),
              if (hasAlert) Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text("⚠️ Stock bajo", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _rowInfo("Disponibles", stock, Colors.black),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade100, valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 8),
          const SizedBox(height: 15),
          _rowInfo("Duración estimada", duration, Colors.cyan),
          _rowInfo("Alerta mínima", alertMin, Colors.black),
          if (hasAlert) ...[
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart_outlined, size: 16),
              label: const Text("Reabastecer"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            )
          ]
        ],
      ),
    );
  }

  // --- BLOQUE 2: RESUMEN (SUFICIENTE, BAJO, CRITICO) ---
  Widget _buildResumenSeccion(Color primary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Column(
        children: [
          _sectionHeader(primary, Icons.inventory_2_outlined, "Resumen de Inventario", "Estado general del stock"),
          const SizedBox(height: 20),
          _statusTile("Stock suficiente", "1", const Color(0xFF00C853), Icons.check_circle_outline),
          const SizedBox(height: 10),
          _statusTile("Stock bajo", "2", const Color(0xFFFFAB00), Icons.warning_amber_rounded),
          const SizedBox(height: 10),
          _statusTile("Stock crítico", "0", const Color(0xFFFF1744), Icons.trending_down),
        ],
      ),
    );
  }

  // --- BLOQUE 3: REABASTECIMIENTO ---
  Widget _buildReabastecimientoSeccion() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFFFFBEA), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange.shade100)),
      child: Column(
        children: [
          _sectionHeader(Colors.orange, Icons.shopping_cart_outlined, "Reabastecimiento", "Medicamentos por comprar"),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("Losartán", style: TextStyle(fontWeight: FontWeight.bold)), Text("Quedan 8 días", style: TextStyle(fontSize: 12, color: Colors.grey))]),
                const Text("Urgente", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: const Text("Ver farmacias cercanas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // --- COMPONENTES REUTILIZABLES ---
  Widget _sectionHeader(Color color, IconData icon, String title, String sub) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white)),
        const SizedBox(width: 15),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12))]),
      ],
    );
  }

  Widget _statusTile(String label, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withOpacity(0.1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)), Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color))]),
          Icon(icon, color: color, size: 30),
        ],
      ),
    );
  }

  Widget _rowInfo(String label, String value, Color vColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)), Text(value, style: TextStyle(color: vColor, fontWeight: FontWeight.bold, fontSize: 12))]),
    );
  }

  PreferredSizeWidget _buildAppBar(Color cyan) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(padding: const EdgeInsets.all(8.0), child: CircleAvatar(backgroundColor: cyan, child: const Icon(Icons.medication, color: Colors.white, size: 20))),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("Dosify", style: TextStyle(color: Color(0xFF006064), fontWeight: FontWeight.bold)), Text("Control inteligente", style: TextStyle(fontSize: 10, color: Colors.grey))]),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Row(children: [
            Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: const [Text("Bienvenida", style: TextStyle(fontSize: 10, color: Colors.grey)), Text("María González", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF006064)))]),
            const SizedBox(width: 10),
            const CircleAvatar(radius: 15, backgroundColor: Color(0xFF00C853), child: Text("MG", style: TextStyle(color: Colors.white, fontSize: 10))),
          ]),
        )
      ],
    );
  }
}