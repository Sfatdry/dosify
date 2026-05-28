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
  String _errorMessage = '';
  
  // Variables dinámicas mapeadas con tu tabla en Supabase
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

  // --- FUNCIÓN PARA CONSULTAR SUPABASE BLINDADA ---
  Future<void> _cargarDatosHistorial() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final user = supabase.auth.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Usuario no autenticado';
            _isLoading = false;
          });
        }
        return;
      }

      // 1. Buscamos el tratamiento de forma segura usando listas
      final List<dynamic> tratamientos = await supabase
          .from('tratamiento')
          .select('id')
          .limit(1);

      // SI NO HAY TRATAMIENTOS: Mostramos todo en 0 y salimos de la carga
      if (tratamientos.isEmpty) {
        if (mounted) {
          setState(() {
            _porcentajeAdherencia = 0.0;
            _dosisTomadas = 0;
            _dosisOmitidas = 0;
            _dosisTardias = 0;
            _totalDosis = 0;
            _isLoading = false; // Rompe el bucle de carga
          });
        }
        return;
      }

      final String tratamientoId = tratamientos.first['id'];

      // 2. Buscamos el historial de cumplimiento de forma segura usando listas
      final List<dynamic> historial = await supabase
          .from('historialcumplimiento')
          .select()
          .eq('tratamiento_id', tratamientoId)
          .order('fecha', ascending: false)
          .limit(1);

      if (mounted) {
        setState(() {
          if (historial.isNotEmpty) {
            final data = historial.first;
            _porcentajeAdherencia = (data['porcentaje_cumplimiento'] as num?)?.toDouble() ?? 0.0;
            _dosisTomadas = data['dosis_a_tiempo'] ?? 0;
            _dosisTardias = data['dosis_tarde'] ?? 0;
            _dosisOmitidas = data['dosis_omitidas'] ?? 0;
            _totalDosis = _dosisTomadas + _dosisTardias + _dosisOmitidas;
          } else {
            // SI EL TRATAMIENTO NO TIENE HISTORIAL AÚN: Ponemos todo en 0
            _porcentajeAdherencia = 0.0;
            _dosisTomadas = 0;
            _dosisOmitidas = 0;
            _dosisTardias = 0;
            _totalDosis = 0;
          }
          _isLoading = false; // Termina de cargar con éxito
        });
      }

    } catch (e) {
      print("Error cargando historial: $e");
      if (mounted) {
        setState(() {
          _isLoading = false; // Evita que se quede el círculo dando vueltas si falla la red
          _errorMessage = 'Ocurrió un problema al obtener los datos: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color textCyan = Color(0xFF006064);
    const Color primaryCyan = Color(0xFF00ACC1);

    // Formatear porcentaje a string visible (Ej: 94%)
    final String porcentajeTexto = "${_porcentajeAdherencia.toStringAsFixed(0)}%";
    // El indicador de progreso requiere un valor entre 0.0 y 1.0
    final double progresoBarra = (_porcentajeAdherencia / 100).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // Botón para refrescar manualmente
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryCyan,
        onPressed: _cargarDatosHistorial,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryCyan))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(_errorMessage, style: const TextStyle(color: Colors.grey, fontSize: 16), textAlign: TextAlign.center),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarDatosHistorial,
                  color: primaryCyan,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                            // 1. ENCABEZADO CON PORCENTAJE DINÁMICO
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
                                  children: [
                                    Text(
                                      porcentajeTexto,
                                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryCyan),
                                    ),
                                    const Text(
                                      "Adherencia",
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),

                            // 2. INDICADOR DE PORCENTAJE
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Porcentaje de adherencia", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                Text(porcentajeTexto, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progresoBarra,
                                minHeight: 10,
                                backgroundColor: const Color(0xFFF1F5F9),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _porcentajeAdherencia >= 80 ? const Color(0xFF10B981) : const Color(0xFFF59E0B)
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // 3. TARJETAS DE MÉTRICAS CON DATOS REALES
                            _buildStatCard("Dosis Tomadas", "$_dosisTomadas", const Color(0xFF10B981), const Color(0xFFECFDF5), Icons.check_circle_outline),
                            const SizedBox(height: 15),
                            _buildStatCard("Dosis Omitidas", "$_dosisOmitidas", const Color(0xFFF43F5E), const Color(0xFFFFF1F2), Icons.cancel_outlined),
                            const SizedBox(height: 15),
                            _buildStatCard("Dosis Tardías", "$_dosisTardias", const Color(0xFFF59E0B), const Color(0xFFFEF3C7), Icons.access_time),
                            const SizedBox(height: 15),

                            // Tarjeta informativa: Total de dosis calculada
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F9FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE0F2FE)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "Total de dosis evaluadas",
                                      style: TextStyle(color: textCyan, fontWeight: FontWeight.w500, fontSize: 15),
                                    ),
                                  ),
                                  Text(
                                    "$_totalDosis",
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),

                            // 4. BANNER MOTIVACIONAL
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _porcentajeAdherencia >= 80 ? primaryCyan : const Color(0xFFF59E0B),
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
                                    child: Icon(
                                      _porcentajeAdherencia >= 80 ? Icons.trending_up : Icons.assignment_late_outlined, 
                                      color: Colors.white, 
                                      size: 24
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _porcentajeAdherencia >= 80 ? "¡Excelente progreso!" : "¡Podemos mejorar!",
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), 
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _porcentajeAdherencia >= 80
                                              ? "Mantén tu adherencia para obtener los mejores resultados en tu tratamiento."
                                              : "Intenta no saltarte tus horas de toma para regularizar la efectividad del medicamento.",
                                          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
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
                ),
    );
  }

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