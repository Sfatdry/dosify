import 'package:flutter/material.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);
    const Color backgroundGray = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: primaryCyan,
            child: Icon(Icons.medication, color: Colors.white, size: 20),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Dosify", style: TextStyle(color: Color(0xFF006064), fontWeight: FontWeight.bold)),
            Text("Control inteligente de medicamentos", style: TextStyle(fontSize: 11, color: Colors.grey)),
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
                  children: const [
                    Text("Bienvenida", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text("María González", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
                  ],
                ),
                const SizedBox(width: 10),
                const CircleAvatar(
                  backgroundColor: Color(0xFF00C853),
                  child: Text("MG", style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tarjeta: Resumen de Inventario (Según inventario_resumen.PNG)
            _buildResumenInventario(primaryCyan),
            
            const SizedBox(height: 30),

            // 2. Tarjeta: Reabastecimiento (Según inventario_reabastecer.PNG)
            _buildReabastecimientoSection(primaryCyan),
          ],
        ),
      ),
    );
  }

  // --- Sección 1: Resumen de Inventario ---
  Widget _buildResumenInventario(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.inventory_2_outlined, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Resumen de Inventario", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
                  Text("Estado general del stock", style: TextStyle(color: Colors.grey)),
                ],
              )
            ],
          ),
          const SizedBox(height: 30),
          _buildStockCounter("Stock suficiente", "1", const Color(0xFF00C853), Icons.inventory_2),
          const SizedBox(height: 15),
          _buildStockCounter("Stock bajo", "2", const Color(0xFFFFAB00), Icons.warning_amber_rounded),
          const SizedBox(height: 15),
          _buildStockCounter("Stock crítico", "0", const Color(0xFFFF1744), Icons.trending_down),
        ],
      ),
    );
  }

  Widget _buildStockCounter(String label, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(count, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  // --- Sección 2: Reabastecimiento ---
  Widget _buildReabastecimientoSection(Color primaryColor) {
    const Color orangeColor = Color(0xFFFF9100);
    
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEA), // Fondo amarillento suave de la imagen
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFECB3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: orangeColor, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Reabastecimiento", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41))),
                  Text("Medicamentos por comprar", style: TextStyle(color: Color(0xFF8D6E63))),
                ],
              )
            ],
          ),
          const SizedBox(height: 25),
          
          // Tarjeta del Medicamento (Losartán)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Losartán", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("Quedan 8 días", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: orangeColor.withOpacity(0.3)),
                  ),
                  child: const Text("Urgente", style: TextStyle(color: orangeColor, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          
          // Botón Ver farmacias cercanas
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.location_on_outlined),
            label: const Text("Ver farmacias cercanas"),
            style: ElevatedButton.styleFrom(
              backgroundColor: orangeColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}