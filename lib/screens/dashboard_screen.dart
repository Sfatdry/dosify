import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:audioplayers/audioplayers.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final String userId;
  const DashboardScreen({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

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
    return DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
      0,
      0,
      0,
    ).toIso8601String();
  }

  String _obtenerFechaHoyFin() {
    final ahora = DateTime.now();
    return DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
      23,
      59,
      59,
    ).toIso8601String();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);
    final String fechaHoy = DateFormat(
      'EEEE, d de MMMM',
      'es',
    ).format(DateTime.now());
    final String horaHoy = DateFormat('h:mm a').format(DateTime.now());
    final String currentUserId = widget.userId;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('tratamiento')
          .stream(primaryKey: ['id'])
          .eq('usuario_id', currentUserId),
      builder: (context, tratSnapshot) {
        final tratamientos = tratSnapshot.data ?? [];
        final tratamientoIds = tratamientos
            .map((t) => t['id'].toString())
            .toSet();

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: supabase.from('medicamento').stream(primaryKey: ['id']),
          builder: (context, medSnapshot) {
            final allMedicamentos = medSnapshot.data ?? [];
            final medicamentos = allMedicamentos
                .where(
                  (med) =>
                      tratamientoIds.contains(med['tratamiento_id'].toString()),
                )
                .toList();
            final medicamentoIds = medicamentos
                .map((m) => m['id'].toString())
                .toSet();

            final Map<String, String> medNombreMap = {
              for (var med in medicamentos)
                med['id'].toString(): med['nombre'] ?? 'Sin nombre',
            };

            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              body: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: SingleChildScrollView(
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
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF006064),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  "Control inteligente de tus medicamentos",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  fechaHoy,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  horaHoy,
                                  style: const TextStyle(
                                    color: primaryCyan,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),

                        // 1. SECCIÓN DE CONTADORES CONECTADOS A SUPABASE EN TIEMPO REAL
                        Row(
                          children: [
                            // Contador Tratamientos Activos
                            Expanded(
                              child: _buildContadorCard(
                                "Tratamientos activos",
                                tratamientos
                                    .where(
                                      (t) =>
                                          t['estado']
                                              ?.toString()
                                              .toLowerCase() ==
                                          'activo',
                                    )
                                    .length
                                    .toString(),
                                Colors.blue.shade400,
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Contador Dosis Tomadas Hoy
                            Expanded(
                              child: StreamBuilder<List<Map<String, dynamic>>>(
                                stream: supabase
                                    .from('dosis')
                                    .stream(primaryKey: ['id'])
                                    .eq('estado', 'tomada'),
                                builder: (context, snapshot) {
                                  final allDosis = snapshot.data ?? [];
                                  final dosisUser = allDosis
                                      .where(
                                        (d) => medicamentoIds.contains(
                                          d['medicamento_id'].toString(),
                                        ),
                                      )
                                      .toList();

                                  final inicioHoy = DateTime.parse(
                                    _obtenerFechaHoyInicio(),
                                  );
                                  final finHoy = DateTime.parse(
                                    _obtenerFechaHoyFin(),
                                  );

                                  final dosisHoy = dosisUser.where((d) {
                                    if (d['fecha_hora'] == null) return false;
                                    final fechaDosis = DateTime.parse(
                                      d['fecha_hora'],
                                    ).toLocal();
                                    return fechaDosis.isAfter(inicioHoy) &&
                                        fechaDosis.isBefore(finHoy);
                                  }).toList();

                                  return _buildContadorCard(
                                    "Dosis tomadas hoy",
                                    dosisHoy.length.toString(),
                                    Colors.green.shade400,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Contador Dosis Pendientes
                            Expanded(
                              child: StreamBuilder<List<Map<String, dynamic>>>(
                                stream: supabase
                                    .from('dosis')
                                    .stream(primaryKey: ['id'])
                                    .eq('estado', 'pendiente'),
                                builder: (context, snapshot) {
                                  final allDosis = snapshot.data ?? [];
                                  final dosisUser = allDosis
                                      .where(
                                        (d) => medicamentoIds.contains(
                                          d['medicamento_id'].toString(),
                                        ),
                                      )
                                      .toList();

                                  final inicioHoy = DateTime.parse(
                                    _obtenerFechaHoyInicio(),
                                  );
                                  final finHoy = DateTime.parse(
                                    _obtenerFechaHoyFin(),
                                  );

                                  final dosisPendientesHoy = dosisUser.where((
                                    d,
                                  ) {
                                    if (d['fecha_hora'] == null) return false;
                                    final fechaDosis = DateTime.parse(
                                      d['fecha_hora'],
                                    ).toLocal();
                                    return fechaDosis.isAfter(inicioHoy) &&
                                        fechaDosis.isBefore(finHoy);
                                  }).toList();

                                  return _buildContadorCard(
                                    "Dosis pendientes",
                                    dosisPendientesHoy.length.toString(),
                                    Colors.orange.shade400,
                                  );
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
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.access_time,
                                          color: primaryCyan,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Próximas dosis",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF006064),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    StreamBuilder<List<Map<String, dynamic>>>(
                                      stream: supabase
                                          .from('dosis')
                                          .stream(primaryKey: ['id'])
                                          .eq('estado', 'pendiente'),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              color: primaryCyan,
                                            ),
                                          );
                                        }

                                        final allDosis = snapshot.data ?? [];
                                        final dosisUser = allDosis
                                            .where(
                                              (d) => medicamentoIds.contains(
                                                d['medicamento_id'].toString(),
                                              ),
                                            )
                                            .toList();

                                        final inicioHoy = DateTime.parse(
                                          _obtenerFechaHoyInicio(),
                                        );
                                        final finHoy = DateTime.parse(
                                          _obtenerFechaHoyFin(),
                                        );

                                        final listaDosis = dosisUser.where((d) {
                                          if (d['fecha_hora'] == null)
                                            return false;
                                          final fechaDosis = DateTime.parse(
                                            d['fecha_hora'],
                                          ).toLocal();
                                          return fechaDosis.isAfter(
                                                inicioHoy,
                                              ) &&
                                              fechaDosis.isBefore(finHoy);
                                        }).toList();

                                        if (listaDosis.isEmpty) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 20,
                                            ),
                                            child: Text(
                                              "No tienes dosis pendientes programadas para hoy.",
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          );
                                        }
                                        return ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: listaDosis.length,
                                          itemBuilder: (context, index) {
                                            final dosis = listaDosis[index];
                                            final String medId =
                                                dosis['medicamento_id']
                                                    ?.toString() ??
                                                '';
                                            final String nombreMed =
                                                medNombreMap[medId] ??
                                                'Medicamento';
                                            return _buildDosisRow(
                                              dosis['id']?.toString() ?? '',
                                              medId,
                                              nombreMed,
                                              'Pendiente',
                                              _formatearHora(
                                                dosis['fecha_hora'] ?? '',
                                              ),
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
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Historial de hoy",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF006064),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    StreamBuilder<List<Map<String, dynamic>>>(
                                      stream: supabase
                                          .from('dosis')
                                          .stream(primaryKey: ['id'])
                                          .eq('estado', 'tomada'),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.green,
                                            ),
                                          );
                                        }

                                        final allDosis = snapshot.data ?? [];
                                        final dosisUser = allDosis
                                            .where(
                                              (d) => medicamentoIds.contains(
                                                d['medicamento_id'].toString(),
                                              ),
                                            )
                                            .toList();

                                        final inicioHoy = DateTime.parse(
                                          _obtenerFechaHoyInicio(),
                                        );
                                        final finHoy = DateTime.parse(
                                          _obtenerFechaHoyFin(),
                                        );

                                        final listaHistorial = dosisUser.where((
                                          d,
                                        ) {
                                          if (d['fecha_hora'] == null)
                                            return false;
                                          final fechaDosis = DateTime.parse(
                                            d['fecha_hora'],
                                          ).toLocal();
                                          return fechaDosis.isAfter(
                                                inicioHoy,
                                              ) &&
                                              fechaDosis.isBefore(finHoy);
                                        }).toList();

                                        if (listaHistorial.isEmpty) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 20,
                                            ),
                                            child: Text(
                                              "Aún no has registrado dosis tomadas hoy.",
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          );
                                        }
                                        return ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: listaHistorial.length,
                                          itemBuilder: (context, index) {
                                            final dosis = listaHistorial[index];
                                            final String medId =
                                                dosis['medicamento_id']
                                                    ?.toString() ??
                                                '';
                                            final String nombreMed =
                                                medNombreMap[medId] ??
                                                'Medicamento';
                                            return _buildDosisRow(
                                              dosis['id']?.toString() ?? '',
                                              medId,
                                              nombreMed,
                                              'Tomada',
                                              _formatearHora(
                                                dosis['fecha_hora'] ?? '',
                                              ),
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

                        // 3. ADHERENCIA DEL DÍA
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: supabase
                              .from('dosis')
                              .stream(primaryKey: ['id']),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox.shrink();
                            
                            final allDosis = snapshot.data ?? [];
                            final dosisUser = allDosis
                                .where((d) => medicamentoIds.contains(d['medicamento_id'].toString()))
                                .toList();
                            
                            final inicioHoy = DateTime.parse(_obtenerFechaHoyInicio());
                            final finHoy = DateTime.parse(_obtenerFechaHoyFin());
                            
                            final dosisHoy = dosisUser.where((d) {
                              if (d['fecha_hora'] == null) return false;
                              final fecha = DateTime.parse(d['fecha_hora']).toLocal();
                              return fecha.isAfter(inicioHoy) && fecha.isBefore(finHoy);
                            }).toList();
                            
                            if (dosisHoy.isEmpty) return const SizedBox.shrink();

                            final tomadas = dosisHoy.where((d) => d['estado'].toString().toLowerCase() == 'tomada').length;
                            final total = dosisHoy.length;
                            final double porcentaje = total > 0 ? (tomadas / total) : 0.0;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 35),
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  CircularPercentIndicator(
                                    radius: 50.0,
                                    lineWidth: 10.0,
                                    animation: true,
                                    percent: porcentaje,
                                    center: Text(
                                      "${(porcentaje * 100).toInt()}%",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                                    ),
                                    circularStrokeCap: CircularStrokeCap.round,
                                    progressColor: porcentaje == 1.0 ? Colors.green : const Color(0xFF00ACC1),
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                  const SizedBox(width: 25),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Adherencia de Hoy",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF006064),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          porcentaje == 1.0
                                              ? "¡Excelente trabajo! Has tomado todas tus dosis de hoy."
                                              : "Has tomado $tomadas de $total dosis programadas para hoy.",
                                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),

                        // 4. SECCIÓN INFERIOR: TRATAMIENTOS ACTIVOS
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.assignment_outlined,
                                    color: Colors.purple,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Tratamientos activos",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF006064),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Builder(
                                builder: (context) {
                                  final activos = tratamientos
                                      .where(
                                        (t) =>
                                            t['estado']
                                                ?.toString()
                                                .toLowerCase() ==
                                            'activo',
                                      )
                                      .toList();
                                  if (activos.isEmpty) {
                                    return const Text(
                                      "No hay tratamientos activos registrados.",
                                      style: TextStyle(color: Colors.grey),
                                    );
                                  }
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: activos.map((trat) {
                                        return _buildTratamientoCard(
                                          trat['id']?.toString() ?? 'ID',
                                          trat['nombre'] ??
                                              'Tratamiento Médico',
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
                        const SizedBox(height: 35),
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: supabase
                              .from('notavoz')
                              .stream(primaryKey: ['id'])
                              .order('fecha', ascending: false),
                          builder: (context, notaSnapshot) {
                            if (notaSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.orange,
                                ),
                              );
                            }

                            final Map<String, String> tratNombreMap = {
                              for (var t in tratamientos)
                                t['id'].toString():
                                    t['nombre'] ?? 'Tratamiento'
                            };

                            final allNotas = notaSnapshot.data ?? [];
                            final userNotas = allNotas
                                .where(
                                  (n) => tratamientoIds.contains(
                                    n['tratamiento_id'].toString(),
                                  ),
                                )
                                .toList();

                            final recentNotas = userNotas.take(3).toList();

                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.mic_rounded,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Notas de voz recientes",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF006064),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  if (recentNotas.isEmpty)
                                    const Text(
                                      "No tienes notas de voz registradas aún.",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    )
                                  else
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: recentNotas.length,
                                      itemBuilder: (context, index) {
                                        final nota = recentNotas[index];
                                        final String rawAudio = nota['url_audio'] ?? 'Sin descripción';
                                        
                                        String audioUrl = '';
                                        String desc = rawAudio;
                                        if (rawAudio.contains('|')) {
                                          final parts = rawAudio.split('|');
                                          audioUrl = parts[0];
                                          desc = parts.sublist(1).join('|');
                                        }

                                        final String tratId =
                                            nota['tratamiento_id']
                                                    ?.toString() ??
                                                '';
                                        final String tratNombre =
                                            tratNombreMap[tratId] ??
                                                'Tratamiento';

                                        String fechaStr = '';
                                        if (nota['fecha'] != null) {
                                          try {
                                            final dt = DateTime.parse(
                                              nota['fecha'].toString(),
                                            ).toLocal();
                                            fechaStr = DateFormat(
                                              'dd/MM/yyyy hh:mm a',
                                            ).format(dt);
                                          } catch (_) {}
                                        }

                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: Colors.orange
                                                .withOpacity(0.05),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.orange
                                                  .withOpacity(0.15),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  if (audioUrl.startsWith('http')) {
                                                    _audioPlayer.play(UrlSource(audioUrl));
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay audio grabado para reproducir.')));
                                                  }
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange
                                                        .withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.play_arrow_rounded,
                                                    color: Colors.orange,
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 15),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      desc,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF006064),
                                                        fontSize: 14,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "Tratamiento: $tratNombre",
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (fechaStr.isNotEmpty)
                                                Text(
                                                  fechaStr,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
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
  }

  // REFACTORIZACIÓN DE COMPONENTES VISUALES LIMPIOS (MANTENIENDO TU DISEÑO ORIGINAL)
  Widget _buildContadorCard(String titulo, String valor, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            valor,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _marcarDosisTomada(String id, String medId) async {
    try {
      await supabase.from('dosis').update({'estado': 'tomada'}).eq('id', id);
      
      // Descuento automático de inventario
      if (medId.isNotEmpty) {
        final List<dynamic> invs = await supabase
            .from('inventario')
            .select()
            .eq('medicamento_id', medId)
            .limit(1);
        if (invs.isNotEmpty) {
          int cant = invs[0]['cantidad_actual'] as int;
          int alertaMinima = invs[0]['alerta_minima'] as int;
          if (cant > 0) {
            cant -= 1;
            await supabase
                .from('inventario')
                .update({'cantidad_actual': cant})
                .eq('id', invs[0]['id']);
            
            if (mounted && cant <= alertaMinima) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("⚠️ ¡Atención! Te quedan $cant pastillas."),
                  backgroundColor: Colors.redAccent,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Dosis marcada como tomada 👏"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al actualizar dosis: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDosisRow(
    String dosisId,
    String medId,
    String nombreMed,
    String estado,
    String hora,
    Color color,
  ) {
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
          Expanded(
            child: Row(
              children: [
                Icon(Icons.medication, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreMed,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006064),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(estado, style: TextStyle(color: color, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                hora,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
              if (estado.toLowerCase() == 'pendiente') ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _marcarDosisTomada(dosisId, medId),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, color: Colors.green, size: 22),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTratamientoCard(
    String id,
    String titulo,
    String inicio,
    String fin,
  ) {
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
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "activo",
              style: TextStyle(
                color: Colors.green,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF006064),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Text(
            "Inicio: $inicio",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            "Fin: $fin",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
