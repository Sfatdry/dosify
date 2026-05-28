import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tratamiento_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String? userName;
  const DashboardScreen({super.key, this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> _listaTratamientos = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _cargarTratamientosDesdeSupabase(); 
  }

  Future<void> _cargarTratamientosDesdeSupabase() async {
    try {
      setState(() => _isLoadingData = true);
      final String? userId = supabase.auth.currentUser?.id;
      PostgrestFilterBuilder query = supabase.from('tratamiento').select();
      
      if (userId != null) {
        query = query.eq('usuario_id', userId);
      }

      final List<dynamic> response = await query.order('fecha_inicio', ascending: true);
      setState(() {
        _listaTratamientos = response;
      });
    } catch (e) {
      debugPrint("Error cargando tratamientos: $e");
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  void _irARegistrarTratamiento() async {
    // Al regresar de la pantalla (ya sea con la flecha atrás), refrescamos los datos
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TratamientoScreen(userName: widget.userName),
      ),
    );
    
    _cargarTratamientosDesdeSupabase(); 
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ENCABEZADO ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "¡Hola, ${widget.userName ?? 'María'}! 👋",
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Tienes 3 dosis pendientes hoy",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                Text(
                  "Sábado, 3 de Mayo\n13:15 PM",
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12, color: Colors.cyan.shade800, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // --- FILA DE CONTADORES ---
            Row(
              children: [
                _buildContadorCard("Tratamientos activos", "${_listaTratamientos.where((t) => t['estado'] == 'Activo').length}", Colors.cyan.shade600),
                const SizedBox(width: 15),
                _buildContadorCard("Dosis tomadas hoy", "3", Colors.green.shade600),
                const SizedBox(width: 15),
                _buildContadorCard("Dosis pendientes", "3", Colors.orange.shade600),
              ],
            ),
            const SizedBox(height: 25),

            // --- DOSIS ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildBloqueSeccion(
                    titulo: "Próximas dosis",
                    subtitulo: "Programadas para hoy",
                    icono: Icons.access_time_filled,
                    iconColor: primaryCyan,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMedicamentoRow("Amoxicilina", "Pendiente", "14:00", "2026-05-03", primaryCyan),
                        _buildMedicamentoRow("Losartán", "Pendiente", "18:00", "2026-05-03", primaryCyan),
                        _buildMedicamentoRow("Metformina", "Pendiente", "20:00", "2026-05-03", primaryCyan),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildBloqueSeccion(
                    titulo: "Historial de hoy",
                    subtitulo: "Dosis completadas",
                    icono: Icons.check_circle,
                    iconColor: const Color(0xFF10B981),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMedicamentoRow("Metformina", "tomada - 08:00", "", "", const Color(0xFF10B981), esCompletado: true),
                        _buildMedicamentoRow("Amoxicilina", "tomada - 06:00", "", "", const Color(0xFF10B981), esCompletado: true),
                        _buildMedicamentoRow("Losartán", "tomada - 06:00", "", "", const Color(0xFF10B981), esCompletado: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // --- TRATAMIENTOS ACTIVOS ---
            _buildBloqueSeccion(
              titulo: "Tratamientos activos",
              subtitulo: "En curso",
              icono: Icons.assignment_rounded,
              iconColor: const Color(0xFFA855F7), 
              child: _isLoadingData
                  ? const Center(child: CircularProgressIndicator(color: primaryCyan))
                  : _listaTratamientos.isEmpty
                      ? const Text("No hay tratamientos activos registrados.")
                      : SizedBox(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _listaTratamientos.length,
                            itemBuilder: (context, index) {
                              final item = _listaTratamientos[index];
                              return _buildTarjetaTratamientoOriginal(item);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryCyan,
        onPressed: _irARegistrarTratamiento,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildContadorCard(String titulo, String valor, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Text(valor, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildBloqueSeccion({required String titulo, required String subtitulo, required IconData icono, required Color iconColor, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 12)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(icono, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  Text(subtitulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildMedicamentoRow(String nombre, String estado, String hora, String fecha, Color color, {bool esCompletado = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0), 
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: esCompletado ? const Color(0xFFECFDF5) : const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: esCompletado ? const Color(0xFFD1FAE5) : const Color(0xFFE0F2FE)),
        ),
        child: Row(
          children: [
            Icon(esCompletado ? Icons.check_circle : Icons.healing, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                  Text(estado, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (hora.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(hora, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
                  Text(fecha, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaTratamientoOriginal(dynamic tratamiento) {
    final String estado = (tratamiento['estado'] ?? 'Activo').toString();

    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF).withOpacity(0.4), 
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: estado.toLowerCase() == 'activo' ? const Color(0xFFD1FAE5) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              estado,
              style: TextStyle(
                color: estado.toLowerCase() == 'activo' ? const Color(0xFF065F46) : Colors.grey.shade700,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            tratamiento['nombre'] ?? 'Sin Nombre',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Inicio: ${tratamiento['fecha_inicio']}", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              Text("Fin: ${tratamiento['fecha_fin']}", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          )
        ],
      ),
    );
  }
}