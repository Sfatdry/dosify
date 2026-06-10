import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistorialScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const HistorialScreen({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
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
            stream: supabase.from('medicamento').stream(primaryKey: ['id']),
            builder: (context, medSnapshot) {
              final allMedicamentos = medSnapshot.data ?? [];
              final userMedicamentos = allMedicamentos
                  .where(
                    (m) => userTratamientoIds.contains(
                      m['tratamiento_id'].toString(),
                    ),
                  )
                  .toList();
              final userMedicamentoIds = userMedicamentos
                  .map((m) => m['id'].toString())
                  .toSet();

              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase.from('dosis').stream(primaryKey: ['id']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryCyan),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error al cargar historial: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final allDosis = snapshot.data ?? [];
                  final listaDosis = allDosis
                      .where(
                        (d) => userMedicamentoIds.contains(
                          d['medicamento_id'].toString(),
                        ),
                      )
                      .toList();

                  int dosisTomadas = 0;
                  int dosisOmitidas = 0;
                  int dosisTardias = 0;

                  for (var dosis in listaDosis) {
                    final String estado =
                        dosis['estado']?.toString().toLowerCase().trim() ?? '';
                    if (estado == 'tomada') {
                      dosisTomadas++;
                    } else if (estado == 'omitida') {
                      dosisOmitidas++;
                    } else if (estado == 'tarde') {
                      dosisTardias++;
                    }
                  }

                  final int totalDosis =
                      dosisTomadas + dosisOmitidas + dosisTardias;
                  final double porcentajeAdherencia = totalDosis > 0
                      ? ((dosisTomadas + dosisTardias) / totalDosis) * 100
                      : 0.0;

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(25),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  isMobile
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Historial de Cumplimiento",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            const Text(
                                              "Seguimiento acumulado del tratamiento",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              "${porcentajeAdherencia.toStringAsFixed(0)}%",
                                              style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: primaryCyan,
                                              ),
                                            ),
                                            const Text(
                                              "Adherencia",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: const [
                                                Text(
                                                  "Historial de Cumplimiento",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                ),
                                                Text(
                                                  "Seguimiento acumulado del tratamiento",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "${porcentajeAdherencia.toStringAsFixed(0)}%",
                                                  style: const TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    color: primaryCyan,
                                                  ),
                                                ),
                                                const Text(
                                                  "Adherencia",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                  const SizedBox(height: 25),

                                  const Text(
                                    "Porcentaje de adherencia total",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: porcentajeAdherencia / 100,
                                      minHeight: 12,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Color(0xFF10B981),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      double spacing = 12;
                                      double itemWidth =
                                          (constraints.maxWidth -
                                              (spacing * 2)) /
                                          3;
                                      return Wrap(
                                        spacing: spacing,
                                        runSpacing: spacing,
                                        children: [
                                          _buildMiniCard(
                                            width: itemWidth,
                                            label: "Dosis Tomadas",
                                            value: dosisTomadas.toString(),
                                            icon: Icons.check_circle_outline,
                                            iconColor: const Color(0xFF10B981),
                                            bgColor: const Color(0xFFECFDF5),
                                            borderColor: const Color(
                                              0xFFA7F3D0,
                                            ),
                                          ),
                                          _buildMiniCard(
                                            width: itemWidth,
                                            label: "Dosis Omitidas",
                                            value: dosisOmitidas.toString(),
                                            icon: Icons.cancel_outlined,
                                            iconColor: const Color(0xFFEF4444),
                                            bgColor: const Color(0xFFFEF2F2),
                                            borderColor: const Color(
                                              0xFFFCA5A5,
                                            ),
                                          ),
                                          _buildMiniCard(
                                            width: itemWidth,
                                            label: "Dosis Tardías",
                                            value: dosisTardias.toString(),
                                            icon: Icons.access_time,
                                            iconColor: const Color(0xFFF59E0B),
                                            bgColor: const Color(0xFFFFFBEB),
                                            borderColor: const Color(
                                              0xFFFDE68A,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 25),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F9FF),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: const Color(0xFFE0F2FE),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Total de dosis registradas",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF0369A1),
                                          ),
                                        ),
                                        Text(
                                          totalDosis.toString(),
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0369A1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: primaryCyan,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.trending_up,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "¡Excelente progreso, ${widget.userName}!",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          "Mantén tu adherencia para obtener los mejores resultados en tu tratamiento.",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
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
              },
            );
          },
        );
      },
    ),
  );
  }

  Widget _buildMiniCard({
    required double width,
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minWidth: 160),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: iconColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
