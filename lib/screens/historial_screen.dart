import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistorialScreen extends StatefulWidget {
  final String userName;

  const HistorialScreen({super.key, required this.userName});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  bool _isLoading = true;

  double _porcentajeAdherencia = 0.0;
  int _dosisTomadas = 0;
  int _dosisOmitidas = 0;
  int _dosisTardias = 0;
  int _totalDosis = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatosHistorial();
  }

  Future<void> _cargarDatosHistorial() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Consultamos de forma real todos los registros acumulados
      final List<dynamic> response = await supabase
          .from('historialcumplimiento')
          .select('dosis_a_tiempo, dosis_tarde, dosis_omitidas');

      if (response.isNotEmpty) {
        int tempTomadas = 0;
        int tempTardias = 0;
        int tempOmitidas = 0;

        for (var row in response) {
          tempTomadas += (row['dosis_a_tiempo'] as num? ?? 0).toInt();
          tempTardias += (row['dosis_tarde'] as num? ?? 0).toInt();
          tempOmitidas += (row['dosis_omitidas'] as num? ?? 0).toInt();
        }

        setState(() {
          _dosisTomadas = tempTomadas;
          _dosisTardias = tempTardias;
          _dosisOmitidas = tempOmitidas;
          _totalDosis = _dosisTomadas + _dosisTardias + _dosisOmitidas;

          if (_totalDosis > 0) {
            _porcentajeAdherencia = ((_dosisTomadas + _dosisTardias) / _totalDosis) * 100;
          } else {
            _porcentajeAdherencia = 0.0;
          }
        });
      }
    } catch (e) {
      print('Error cargando historial acumulado: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryCyan))
          : RefreshIndicator(
              onRefresh: _cargarDatosHistorial,
              color: primaryCyan,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(25),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- CARD PRINCIPAL SUPERIOR ORIGINAL ---
                        Container(
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text("Historial de Cumplimiento", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                      Text("Seguimiento acumulado del tratamiento", style: TextStyle(fontSize: 14, color: Colors.grey)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("${_porcentajeAdherencia.toStringAsFixed(0)}%", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryCyan)),
                                      const Text("Adherencia", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 25),

                              const Text("Porcentaje de adherencia total", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: _porcentajeAdherencia / 100,
                                  minHeight: 12,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                                ),
                              ),
                              const SizedBox(height: 30),

                              // --- LAS TRES MINI TARJETAS ORIGINALES ASOCIADAS AL FLUJO ---
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  double spacing = 12;
                                  double itemWidth = (constraints.maxWidth - (spacing * 2)) / 3;
                                  return Wrap(
                                    spacing: spacing,
                                    runSpacing: spacing,
                                    children: [
                                      _buildMiniCard(
                                        width: itemWidth,
                                        label: "Dosis Tomadas",
                                        value: _dosisTomadas.toString(),
                                        icon: Icons.check_circle_outline,
                                        iconColor: const Color(0xFF10B981),
                                        bgColor: const Color(0xFFECFDF5),
                                        borderColor: const Color(0xFFA7F3D0),
                                      ),
                                      _buildMiniCard(
                                        width: itemWidth,
                                        label: "Dosis Omitidas",
                                        value: _dosisOmitidas.toString(),
                                        icon: Icons.cancel_outlined,
                                        iconColor: const Color(0xFFEF4444),
                                        bgColor: const Color(0xFFFEF2F2),
                                        borderColor: const Color(0xFFFCA5A5),
                                      ),
                                      _buildMiniCard(
                                        width: itemWidth,
                                        label: "Dosis Tardías",
                                        value: _dosisTardias.toString(),
                                        icon: Icons.access_time,
                                        iconColor: const Color(0xFFF59E0B),
                                        bgColor: const Color(0xFFFFFBEB),
                                        borderColor: const Color(0xFFFDE68A),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 25),

                              // TOTAL DE DOSIS CON TU DISEÑO CELESTE
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F9FF),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: const Color(0xFFE0F2FE)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Total de dosis registradas", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF0369A1))),
                                    Text(_totalDosis.toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),

                        // --- TU BANNER INFERIOR CYAN ORIGINAL CON TU TEXTO ---
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: primaryCyan, borderRadius: BorderRadius.circular(18)),
                          child: Row(
                            children: [
                              const Icon(Icons.trending_up, color: Colors.white, size: 28),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("¡Excelente progreso, ${widget.userName}!", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    const Text("Mantén tu adherencia para obtener los mejores resultados en tu tratamiento.", style: TextStyle(color: Colors.white, fontSize: 13)),
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
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(15), border: Border.all(color: borderColor, width: 1)),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: iconColor, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: iconColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}