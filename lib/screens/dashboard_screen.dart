import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  const DashboardScreen({super.key, required this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isLoading = true;
  
  Map<String, dynamic>? _proximoRecordatorio;
  int _dosisTomadasHoy = 0;

  @override
  void initState() {
    super.initState();
    _obtenerDatosDashboard();
  }

  Future<void> _obtenerDatosDashboard() async {
    try {
      setState(() => _isLoading = true);
      
      // 1. Buscamos el recordatorio de la tabla tratamiento
      final List<dynamic> tx = await supabase
          .from('tratamiento')
          .select('id, fecha_hora, tipo_alerta')
          .eq('recordatorio_activo', true)
          .limit(1);

      // 2. Sumamos las dosis tomadas estrictamente HOY desde el historial
      final String hoyString = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final List<dynamic> historialHoy = await supabase
          .from('historialcumplimiento')
          .select('dosis_a_tiempo')
          .gte('fecha', '$hoyString 00:00:00')
          .lte('fecha', '$hoyString 23:59:59');

      int tomadasHoy = 0;
      for (var row in historialHoy) {
        tomadasHoy += (row['dosis_a_tiempo'] as num? ?? 0).toInt();
      }

      setState(() {
        _proximoRecordatorio = tx.isNotEmpty ? tx.first : null;
        _dosisTomadasHoy = tomadasHoy;
      });
    } catch (e) {
      print("Error cargando Dashboard: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- REGISTRAR EN VIVO DESDE EL BOTÓN ---
  Future<void> _registrarDosis() async {
    setState(() => _isLoading = true);
    try {
      // Inyectamos fila en historialcumplimiento conectada dinámicamente
      await supabase.from('historialcumplimiento').insert({
        'fecha': DateTime.now().toIso8601String(),
        'dosis_a_tiempo': 1,
        'dosis_tarde': 0,
        'dosis_omitidas': 0,
        'porcentaje_cumplimiento': 100
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Dosis registrada y añadida al historial! 💪🎉"), backgroundColor: Color(0xFF10B981)),
      );

      await _obtenerDatosDashboard(); // Recargar contadores visuales inmediatamente
    } catch (e) {
      print("Error al registrar dosis: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);
    
    // Formateamos la hora rescatada de la base de datos
    String horaVisual = "10:40 AM"; // Default estético si no hay datos
    if (_proximoRecordatorio != null && _proximoRecordatorio!['fecha_hora'] != null) {
      final dt = DateTime.parse(_proximoRecordatorio!['fecha_hora']).toLocal();
      horaVisual = DateFormat('hh:mm a').format(dt);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: primaryCyan))
          : RefreshIndicator(
              onRefresh: _obtenerDatosDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- TU CARD DE INDICADOR DE DOSIS HOY ORIGINAL ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          const Text("Dosis tomadas hoy", style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 10),
                          Text(
                            "$_dosisTomadasHoy",
                            style: const TextStyle(fontSize: 54, fontWeight: FontWeight.bold, color: primaryCyan),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    const Text("Próxima dosis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 12),

                    // --- TU ITEM DE LISTA DE MEDICAMENTO ORIGINAL PERO CON HORA REAL ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: const Color(0xFFE0F7FA), borderRadius: BorderRadius.circular(14)),
                                child: const Icon(Icons.medication, color: primaryCyan, size: 26),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Paracetamol", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                                  Text(
                                    "Alerta: ${_proximoRecordatorio?['tipo_alerta'] ?? 'NORMAL'}",
                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            horaVisual,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- TU BOTÓN ORIGINAL ACCIONABLE MÁGICO ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _registrarDosis,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text(
                          "TOMAR DOSIS",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}