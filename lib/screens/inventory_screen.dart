import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryScreen extends StatefulWidget {
  final String userName;
  final String userId;
  final VoidCallback? onVerFarmacias;

  const InventoryScreen({
    super.key,
    required this.userName,
    required this.userId,
    this.onVerFarmacias,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);
    final SupabaseClient supabase = Supabase.instance.client;
    final String currentUserId = widget.userId;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('tratamiento')
            .stream(primaryKey: ['id'])
            .eq('usuario_id', currentUserId),
        builder: (context, tratSnapshot) {
          final userTratamientos = tratSnapshot.data ?? [];
          final userTratamientoIds = userTratamientos
              .map((t) => t['id'].toString())
              .toSet();

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase
                .from('medicamento')
                .stream(primaryKey: ['id'])
                .order('nombre', ascending: true),
            builder: (context, medSnapshot) {
              if (medSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryCyan),
                );
              }

              if (medSnapshot.hasError) {
                return Center(
                  child: Text(
                    "Error al cargar medicamentos: ${medSnapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final allMedicamentos = medSnapshot.data ?? [];
              final medicamentos = allMedicamentos
                  .where(
                    (m) => userTratamientoIds.contains(
                      m['tratamiento_id'].toString(),
                    ),
                  )
                  .toList();

              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase.from('inventario').stream(primaryKey: ['id']),
                builder: (context, invSnapshot) {
                  if (invSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryCyan),
                    );
                  }

                  if (invSnapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error al cargar inventario: ${invSnapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final inventarios = invSnapshot.data ?? [];
                  final Map<String, Map<String, dynamic>> inventarioMap = {
                    for (var inv in inventarios)
                      inv['medicamento_id'].toString(): inv,
                  };

                  // 1. Calcular métricas para el resumen de inventario
                  int suficiente = 0;
                  int bajo = 0;
                  int critico = 0;

                  final List<Map<String, dynamic>> reabastecimientoList = [];

                  for (var med in medicamentos) {
                    final String id = med['id'].toString();
                    final inv = inventarioMap[id];
                    final int cantidadInicial = inv?['cantidad_inicial'] ?? 30;
                    final int cantidadActual =
                        inv?['cantidad_actual'] ?? cantidadInicial;
                    final double ratio = cantidadInicial > 0
                        ? (cantidadActual / cantidadInicial)
                        : 0.0;

                    // Clasificación de stock
                    if (ratio <= 0.15 || cantidadActual <= 3) {
                      critico++;
                    } else if (ratio <= 0.35) {
                      bajo++;
                    } else {
                      suficiente++;
                    }

                    // Si el stock es bajo o crítico (ratio <= 0.30 o cantidadActual <= 5)
                    if (ratio <= 0.30 || cantidadActual <= 5) {
                      reabastecimientoList.add({
                        'nombre': med['nombre'],
                        'cantidad_inicial': cantidadInicial,
                        'cantidad_actual': cantidadActual,
                        'duracion_dias': med['duracion_dias'] ?? 7,
                      });
                    }
                  }

                  return Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: RefreshIndicator(
                        onRefresh: () async {
                          setState(() {});
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 1. FILA DE MEDICAMENTOS (Scroll Horizontal)
                            const Text(
                              "Medicamentos en uso",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006064),
                              ),
                            ),
                            const SizedBox(height: 20),
                            medicamentos.isEmpty
                                ? Container(
                                    height: 150,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "No hay medicamentos registrados.",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(medicamentos.length, (
                                        index,
                                      ) {
                                        final med = medicamentos[index];
                                        final String id = med['id'].toString();
                                        final String nombre =
                                            med['nombre'] ?? 'Sin nombre';
                                        final inv = inventarioMap[id];
                                        final int cantidadInicial =
                                            inv?['cantidad_inicial'] ?? 30;
                                        final int cantidadActual =
                                            inv?['cantidad_actual'] ??
                                            cantidadInicial;
                                        final double progress =
                                            cantidadInicial > 0
                                            ? (cantidadActual / cantidadInicial)
                                                  .clamp(0.0, 1.0)
                                            : 0.0;
                                        final int duracionDias =
                                            med['duracion_dias'] ?? 7;

                                        // Determinar color y alertas según estado
                                        Color color;
                                        bool hasAlert = false;
                                        if (progress <= 0.15 ||
                                            cantidadActual <= 3) {
                                          color = Colors.pink;
                                          hasAlert = true;
                                        } else if (progress <= 0.35) {
                                          color = Colors.orange;
                                          hasAlert = true;
                                        } else {
                                          color = Colors.teal;
                                        }

                                        final String alertMinText =
                                            "${(cantidadInicial * 0.2).round()} unidades";

                                        return Padding(
                                          padding: EdgeInsets.only(
                                            right:
                                                index < medicamentos.length - 1
                                                ? 20.0
                                                : 0.0,
                                          ),
                                          child: _buildMedCard(
                                            nombre,
                                            "$cantidadActual / $cantidadInicial",
                                            progress,
                                            "$duracionDias días",
                                            alertMinText,
                                            color,
                                            hasAlert,
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                            const SizedBox(height: 40),

                            // 2. RESUMEN DE INVENTARIO
                            _buildResumenSeccion(
                              primaryCyan,
                              suficiente,
                              bajo,
                              critico,
                            ),
                            const SizedBox(height: 40),

                            // 3. REABASTECIMIENTO
                            _buildReabastecimientoSeccion(reabastecimientoList),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              );
            },
          );
        },
      ),
    );
  }

  // --- BLOQUE 2: RESUMEN ---
  Widget _buildResumenSeccion(
    Color primary,
    int suficiente,
    int bajo,
    int critico,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15),
        ],
      ),
      child: Column(
        children: [
          _sectionHeader(
            primary,
            Icons.inventory_2_outlined,
            "Resumen de Inventario",
            "Estado general del stock",
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _statusTile(
                "Stock suficiente",
                suficiente.toString(),
                const Color(0xFF00C853),
                Icons.check_circle_outline,
              ),
              _statusTile(
                "Stock bajo",
                bajo.toString(),
                const Color(0xFFFFAB00),
                Icons.warning_amber_rounded,
              ),
              _statusTile(
                "Stock crítico",
                critico.toString(),
                const Color(0xFFFF1744),
                Icons.trending_down,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- BLOQUE 3: REABASTECIMIENTO ---
  Widget _buildReabastecimientoSeccion(
    List<Map<String, dynamic>> reabastecimientoList,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        children: [
          _sectionHeader(
            Colors.orange,
            Icons.shopping_cart_outlined,
            "Reabastecimiento",
            "Medicamentos por comprar",
          ),
          const SizedBox(height: 30),
          reabastecimientoList.isEmpty
              ? Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Text(
                      "Todo al día. No tienes medicamentos por comprar.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: reabastecimientoList.map((med) {
                    final String nombre = med['nombre'] ?? 'Sin nombre';
                    final int cantidadInicial = med['cantidad_inicial'] ?? 30;
                    final int cantidadActual =
                        med['cantidad_actual'] ?? cantidadInicial;
                    final int duracionDias = med['duracion_dias'] ?? 7;

                    final double ratio = cantidadInicial > 0
                        ? (cantidadActual / cantidadInicial)
                        : 0.0;
                    final int diasRestantes = (ratio * duracionDias).round();

                    final String urgenciaText =
                        ratio <= 0.15 || cantidadActual <= 3
                        ? "Urgente"
                        : "Bajo Stock";
                    final Color urgenciaColor =
                        ratio <= 0.15 || cantidadActual <= 3
                        ? Colors.red
                        : Colors.orange;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                "Quedan $cantidadActual unidades (~$diasRestantes días)",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            urgenciaText,
                            style: TextStyle(
                              color: urgenciaColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: widget.onVerFarmacias,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(300, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "Ver farmacias cercanas",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(Color color, IconData icon, String title, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(sub, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _statusTile(String label, String count, Color color, IconData icon) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
              Text(
                count,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Icon(icon, color: color, size: 35),
        ],
      ),
    );
  }

  Widget _rowInfo(String label, String value, Color vColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(color: vColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMedCard(
    String name,
    String stock,
    double progress,
    String duration,
    String alertMin,
    Color color,
    bool hasAlert,
  ) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(Icons.medication_outlined, color: color),
          ),
          const SizedBox(height: 20),
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _rowInfo("Disponibles", stock, Colors.black),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
          const SizedBox(height: 20),
          _rowInfo("Duración estimada", duration, Colors.cyan),
          _rowInfo("Alerta mínima", alertMin, Colors.black),
        ],
      ),
    );
  }
}
