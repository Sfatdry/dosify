import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  const DashboardScreen({super.key, required this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Formateadores útiles para limpiar fechas y horas de Supabase
  String _formatearHora(String timestampStr) {
    try {
      final dateTime = DateTime.parse(timestampStr).toLocal();
      return DateFormat('HH:mm').format(dateTime);
    } catch (_) {
      return "--:--";
    }
  }

  String _formatearFecha(String? fechaStr) {
    if (fechaStr == null) return "Sin fecha";
    try {
      final dateTime = DateTime.parse(fechaStr);
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (_) {
      return fechaStr;
    }
  }

  // Helper para obtener el rango del día de hoy en formato ISO string UTC/Local para filtrado preciso
  String _obtenerFechaHoyInicio() {
    final ahora = DateTime.now();
    return DateTime(ahora.year, ahora.month, ahora.day, 0, 0, 0).toIso8601String();
  }

  String _obtenerFechaHoyFin() {
    final ahora = DateTime.now();
    return DateTime(ahora.year, ahora.month, ahora.day, 23, 59, 59).toIso8601String();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);
    final String fechaHoy = DateFormat('EEEE, d de MMMM', 'es').format(DateTime.now());
    final String horaHoy = DateFormat('h:mm a').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENCABEZADO REAL DINÁMICO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "¡Hola, ${widget.userName}! 👋",
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF006064)),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Control inteligente de tus medicamentos",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(fechaHoy, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                    Text(horaHoy, style: const TextStyle(color: primaryCyan, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 35),

            // 1. SECCIÓN DE CONTADORES CONECTADOS A SUPABASE EN TIEMPO REAL
            Row(
              children: [
                // Contador Tratamientos Activos (Filtra por 'Activo' en minúscula/mayúscula según BD corporativa)
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: supabase.from('tratamiento').stream(primaryKey: ['id']).eq('estado', 'Activo'),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return _buildContadorCard("Tratamientos activos", count.toString(), Colors.blue.shade400);
                    },
                  ),
                ),
                const SizedBox(width: 20),
                // Contador Dosis Tomadas Hoy (Filtra de forma segura por el estado y optimiza reactividad)
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: supabase.from('dosis').stream(primaryKey: ['id']).eq('estado', 'tomada'),
                    builder: (context, snapshot) {
                      // Filtrado dinámico en memoria para asegurar que correspondan ÚNICAMENTE al día de hoy
                      final inicioHoy = DateTime.parse(_obtenerFechaHoyInicio());
                      final finHoy = DateTime.parse(_obtenerFechaHoyFin());
                      
                      final dosisHoy = snapshot.data?.where((d) {
                        if (d['fecha_hora'] == null) return false;
                        final fechaDosis = DateTime.parse(d['fecha_hora']).toLocal();
                        return fechaDosis.isAfter(inicioHoy) && fechaDosis.isBefore(finHoy);
                      }).toList() ?? [];

                      return _buildContadorCard("Dosis tomadas hoy", dosisHoy.length.toString(), Colors.green.shade400);
                    },
                  ),
                ),
                const SizedBox(width: 20),
                // Contador Dosis Pendientes
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: supabase.from('dosis').stream(primaryKey: ['id']).eq('estado', 'pendiente'),
                    builder: (context, snapshot) {
                      final inicioHoy = DateTime.parse(_obtenerFechaHoyInicio());
                      final finHoy = DateTime.parse(_obtenerFechaHoyFin());
                      
                      final dosisPendientesHoy = snapshot.data?.where((d) {
                        if (d['fecha_hora'] == null) return false;
                        final fechaDosis = DateTime.parse(d['fecha_hora']).toLocal();
                        return fechaDosis.isAfter(inicioHoy) && fechaDosis.isBefore(finHoy);
                      }).toList() ?? [];

                      return _buildContadorCard("Dosis pendientes", dosisPendientesHoy.length.toString(), Colors.orange.shade400);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),

            // 2. PRÓXIMAS DOSIS Y HISTORIAL EN PARALELO
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bloque Izquierdo: Próximas Dosis (Pendientes)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.access_time, color: primaryCyan),
                            SizedBox(width: 10),
                            Text("Próximas dosis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
                          ],
                        ),
                        const SizedBox(height: 20),
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: supabase.from('dosis').stream(primaryKey: ['id']).eq('estado', 'pendiente'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(color: primaryCyan));
                            }
                            
                            // Filtrar cronológicamente para el día de hoy
                            final inicioHoy = DateTime.parse(_obtenerFechaHoyInicio());
                            final finHoy = DateTime.parse(_obtenerFechaHoyFin());
                            
                            final listaDosis = snapshot.data?.where((d) {
                              if (d['fecha_hora'] == null) return false;
                              final fechaDosis = DateTime.parse(d['fecha_hora']).toLocal();
                              return fechaDosis.isAfter(inicioHoy) && fechaDosis.isBefore(finHoy);
                            }).toList() ?? [];

                            if (listaDosis.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text("No tienes dosis pendientes programadas para hoy.", style: TextStyle(color: Colors.grey)),
                              );
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: listaDosis.length,
                              itemBuilder: (context, index) {
                                final dosis = listaDosis[index];
                                return _buildDosisRow(
                                  dosis['medicamento_id']?.toString() ?? 'Medicamento', 
                                  'Pendiente', 
                                  _formatearHora(dosis['fecha_hora'] ?? ''), 
                                  Colors.orange,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 25),

                // Bloque Derecho: Historial de Hoy (Tomadas)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.check_circle_outline, color: Colors.green),
                            SizedBox(width: 10),
                            Text("Historial de hoy", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
                          ],
                        ),
                        const SizedBox(height: 20),
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: supabase.from('dosis').stream(primaryKey: ['id']).eq('estado', 'tomada'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(color: Colors.green));
                            }

                            // Filtrar cronológicamente para el día de hoy
                            final inicioHoy = DateTime.parse(_obtenerFechaHoyInicio());
                            final finHoy = DateTime.parse(_obtenerFechaHoyFin());
                            
                            final listaHistorial = snapshot.data?.where((d) {
                              if (d['fecha_hora'] == null) return false;
                              final fechaDosis = DateTime.parse(d['fecha_hora']).toLocal();
                              return fechaDosis.isAfter(inicioHoy) && fechaDosis.isBefore(finHoy);
                            }).toList() ?? [];

                            if (listaHistorial.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text("Aún no has registrado dosis tomadas hoy.", style: TextStyle(color: Colors.grey)),
                              );
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: listaHistorial.length,
                              itemBuilder: (context, index) {
                                final dosis = listaHistorial[index];
                                return _buildDosisRow(
                                  dosis['medicamento_id']?.toString() ?? 'Medicamento', 
                                  'tomada', 
                                  _formatearHora(dosis['fecha_hora'] ?? ''), 
                                  Colors.green,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),

            // 3. SECCIÓN INFERIOR: TRATAMIENTOS ACTIVOS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.assignment_outlined, color: Colors.purple),
                      SizedBox(width: 10),
                      Text("Tratamientos activos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: supabase.from('tratamiento').stream(primaryKey: ['id']).eq('estado', 'Activo'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.purple));
                      }
                      final tratamientos = snapshot.data ?? [];
                      if (tratamientos.isEmpty) {
                        return const Text("No hay tratamientos activos registrados.", style: TextStyle(color: Colors.grey));
                      }
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: tratamientos.map((trat) {
                            return _buildTratamientoCard(
                              trat['id']?.toString() ?? 'ID',
                              trat['nombre'] ?? 'Tratamiento Médico', 
                              _formatearFecha(trat['fecha_inicio']),
                              _formatearFecha(trat['fecha_fin']),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // REFACTORIZACIÓN DE COMPONENTES VISUALES LIMPIOS (MANTENIENDO TU DISEÑO ORIGINAL)
  Widget _buildContadorCard(String titulo, String valor, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Text(valor, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildDosisRow(String nombreMed, String estado, String hora, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.medication, color: color, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombreMed, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064))),
                  Text(estado, style: TextStyle(color: color, fontSize: 12)),
                ],
              )
            ],
          ),
          Text(hora, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildTratamientoCard(String id, String titulo, String inicio, String fin) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.purple.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
            child: const Text("activo", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF006064)), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Text("Inicio: $inicio", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text("Fin: $fin", style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}