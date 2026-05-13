import 'package:flutter/material.dart';

class InventoryScreen extends StatelessWidget {
  final String userName;

  // El constructor NO debe tener 'const' antes de InventoryScreen
  InventoryScreen({super.key, required this.userName}); 
  
  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(primaryCyan),
      body: Center( // <--- Esto centra todo horizontalmente
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900), // <--- Limita el ancho para que no se vea gigante
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // <--- Centra los elementos de la columna
              children: [
                // 1. FILA DE MEDICAMENTOS (Scroll Horizontal)
                const Text(
                  "Medicamentos en uso", 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006064))
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMedCard("Amoxicilina", "21 / 30", 0.7, "7 días", "10 unidades", Colors.teal, false),
                      const SizedBox(width: 20),
                      _buildMedCard("Losartán", "8 / 30", 0.26, "8 días", "10 unidades", Colors.pink, true),
                      const SizedBox(width: 20),
                      _buildMedCard("Metformina", "28 / 60", 0.46, "14 días", "15 unidades", Colors.orange, false),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // 2. RESUMEN DE INVENTARIO (Centrado)
                _buildResumenSeccion(primaryCyan),
                const SizedBox(height: 40),

                // 3. REABASTECIMIENTO (Centrado)
                _buildReabastecimientoSeccion(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- BLOQUE 2: RESUMEN (CENTRADITO) ---
  Widget _buildResumenSeccion(Color primary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)]
      ),
      child: Column(
        children: [
          _sectionHeader(primary, Icons.inventory_2_outlined, "Resumen de Inventario", "Estado general del stock"),
          const SizedBox(height: 30),
          // Usamos Wrap para que los contadores se acomoden bonito
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _statusTile("Stock suficiente", "1", const Color(0xFF00C853), Icons.check_circle_outline),
              _statusTile("Stock bajo", "2", const Color(0xFFFFAB00), Icons.warning_amber_rounded),
              _statusTile("Stock crítico", "0", const Color(0xFFFF1744), Icons.trending_down),
            ],
          ),
        ],
      ),
    );
  }

  // --- BLOQUE 3: REABASTECIMIENTO ---
  Widget _buildReabastecimientoSeccion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEA), 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.orange.shade100)
      ),
      child: Column(
        children: [
          _sectionHeader(Colors.orange, Icons.shopping_cart_outlined, "Reabastecimiento", "Medicamentos por comprar"),
          const SizedBox(height: 30),
          Container(
            constraints: const BoxConstraints(maxWidth: 500), // Para que la tarjeta de Losartán no sea infinita
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: const [
                    Text("Losartán", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
                    Text("Quedan 8 días", style: TextStyle(fontSize: 14, color: Colors.grey))
                  ]
                ),
                const Text("Urgente", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange, 
              minimumSize: const Size(300, 55), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),
            child: const Text("Ver farmacias cercanas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // Los demás widgets auxiliares (_buildMedCard, _statusTile, etc.) se mantienen igual que arriba
  // solo asegúrate de cerrar bien los paréntesis.
  
  Widget _sectionHeader(Color color, IconData icon, String title, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Centra el encabezado
      children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white)),
        const SizedBox(width: 15),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(color: Colors.grey))]),
      ],
    );
  }

  Widget _statusTile(String label, String count, Color color, IconData icon) {
    return Container(
      width: 220, // Ancho fijo para que se vean uniformes
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withOpacity(0.1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)), Text(count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color))]),
          Icon(icon, color: color, size: 35),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color cyan) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(padding: const EdgeInsets.all(8.0), child: CircleAvatar(backgroundColor: cyan, child: const Icon(Icons.medication, color: Colors.white))),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("Dosify", style: TextStyle(color: Color(0xFF006064), fontWeight: FontWeight.bold)), Text("Control inteligente", style: TextStyle(fontSize: 12, color: Colors.grey))]),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(children: [
            Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: const [Text("Bienvenida", style: TextStyle(fontSize: 10, color: Colors.grey)), Text("María González", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF006064)))]),
            const SizedBox(width: 12),
            const CircleAvatar(backgroundColor: Color(0xFF00C853), child: Text("MG", style: TextStyle(color: Colors.white, fontSize: 12))),
          ]),
        )
      ],
    );
  }

  Widget _rowInfo(String label, String value, Color vColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value, style: TextStyle(color: vColor, fontWeight: FontWeight.bold))]),
    );
  }

  Widget _buildMedCard(String name, String stock, double progress, String duration, String alertMin, Color color, bool hasAlert) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(Icons.medication_outlined, color: color)),
          const SizedBox(height: 20),
          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _rowInfo("Disponibles", stock, Colors.black),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade100, valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 10),
          const SizedBox(height: 20),
          _rowInfo("Duración estimada", duration, Colors.cyan),
          _rowInfo("Alerta mínima", alertMin, Colors.black),
        ],
      ),
    );
  }
}