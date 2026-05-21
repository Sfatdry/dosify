import 'package:flutter/material.dart';

class HistorialScreen extends StatelessWidget {
  final String userName;

  const HistorialScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    const Color textCyan = Color(0xFF006064);
    const Color primaryCyan = Color(0xFF00ACC1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 15,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. ENCABEZADO CON PORCENTAJE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Historial de\nCumplimiento",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textCyan, height: 1.2),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Seguimiento del\ntratamiento",
                          style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.2),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          "94%",
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryCyan),
                        ),
                        Text(
                          "Adherencia",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // 2. INDICADOR DE PORCENTAJE (TEXTO MINI + BARRA DE PROGRESO)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Porcentaje de adherencia", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("94%", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.94,
                    minHeight: 10,
                    backgroundColor: Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)), // Verde Adherencia
                  ),
                ),
                const SizedBox(height: 30),

                // 3. TARJETAS DE MÉTRICAS
                _buildStatCard("Dosis Tomadas", "40", const Color(0xFF10B981), const Color(0xFFECFDF5), Icons.check_circle_outline),
                const SizedBox(height: 15),
                _buildStatCard("Dosis Omitidas", "1", const Color(0xFFF43F5E), const Color(0xFFFFF1F2), Icons.cancel_outlined),
                const SizedBox(height: 15),
                _buildStatCard("Dosis Tardías", "2", const Color(0xFFF59E0B), const Color(0xFFFEF3C7), Icons.access_time),
                const SizedBox(height: 15),

                // Tarjeta informativa: Total de dosis
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE0F2FE)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Expanded(
                        child: Text(
                          "Total de dosis en el\ntratamiento",
                          style: TextStyle(color: textCyan, fontWeight: FontWeight.w500, fontSize: 15),
                        ),
                      ),
                      Text(
                        "43",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // 4. BANNER MOTIVACIONAL INFERIOR
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryCyan,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.trending_up, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "¡Excelente progreso!",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Mantén tu adherencia para obtener los mejores resultados en tu tratamiento.",
                              style: TextStyle(
                                color: Colors.white70, 
                                fontSize: 13, 
                                height: 1.3,
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
  }

  // --- WIDGET AUXILIAR PARA LAS TARJETAS DE ESTADÍSTICAS ---
  Widget _buildStatCard(String title, String count, Color color, Color bgColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  count,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}