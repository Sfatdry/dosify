import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotaDeVozScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const NotaDeVozScreen({super.key, required this.userName, required this.userId});

  @override
  State<NotaDeVozScreen> createState() => _NotaDeVozScreenState();
}

class _NotaDeVozScreenState extends State<NotaDeVozScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  bool _isRecording = false;
  bool _isSaving = false;
  bool _hasRecording = false;

  final TextEditingController _notaController = TextEditingController();

  // Tratamientos
  List<Map<String, dynamic>> _tratamientos = [];
  String? _tratamientoSeleccionadoId;

  @override
  void initState() {
    super.initState();
    _cargarTratamientos();
  }

  Future<void> _cargarTratamientos() async {
    final String userId = widget.userId;
    final data = await supabase
        .from('tratamiento')
        .select('id, nombre')
        .eq('usuario_id', userId)
        .order('nombre', ascending: true);
    if (mounted) {
      setState(() => _tratamientos = List<Map<String, dynamic>>.from(data));
    }
  }

  void _toggleGrabacion() {
    setState(() {
      if (_isRecording) {
        // Detener grabación
        _isRecording = false;
        _hasRecording = true;
        if (_notaController.text.isEmpty) {
          _notaController.text =
              "Nota de voz grabada el ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
        }
      } else {
        // Iniciar grabación
        _isRecording = true;
        _hasRecording = false;
      }
    });
  }

  Future<void> _guardarNota() async {
    if (!_hasRecording) {
      _snack("Graba una nota de voz antes de guardar", Colors.orange);
      return;
    }
    if (_tratamientoSeleccionadoId == null) {
      _snack("Selecciona un tratamiento asociado", Colors.orange);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await supabase.from('notavoz').insert({
        'tratamiento_id': _tratamientoSeleccionadoId,
        'url_audio': _notaController.text.trim().isNotEmpty
            ? _notaController.text.trim()
            : "nota_${DateTime.now().millisecondsSinceEpoch}",
        'fecha': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        _snack("Nota de voz guardada correctamente ✅", Colors.green);
        setState(() {
          _isRecording = false;
          _hasRecording = false;
          _tratamientoSeleccionadoId = null;
        });
        _notaController.clear();
      }
    } catch (e) {
      if (mounted) _snack("Error al guardar: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _eliminarNota(String id) async {
    try {
      await supabase.from('notavoz').delete().eq('id', id);
    } catch (e) {
      if (mounted) _snack("Error al eliminar: $e", Colors.red);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  void dispose() {
    _notaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);
    final String currentUserId = widget.userId;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('tratamiento').stream(primaryKey: ['id']).eq('usuario_id', currentUserId),
        builder: (context, tratSnapshot) {
          final userTratamientos = tratSnapshot.data ?? [];
          final userTratamientoIds = userTratamientos.map((t) => t['id'].toString()).toSet();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
            child: Center(
              child: Column(
                children: [
                  // ── FORMULARIO ────────────────────────────────────────
                  Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.all(35),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Encabezado
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryCyan,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.mic,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Text(
                              "Nota de Voz",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006064),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Selector de tratamiento
                        const Text(
                          "Tratamiento asociado",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF006064),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _tratamientos.isEmpty
                            ? const Text(
                                "Crea un tratamiento primero",
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F9FF),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: const Color(0xFFBAE6FD),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    hint: const Text(
                                      "Selecciona un tratamiento",
                                      style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 14,
                                      ),
                                    ),
                                    value: _tratamientoSeleccionadoId,
                                    onChanged: (val) => setState(
                                      () => _tratamientoSeleccionadoId = val,
                                    ),
                                    items: _tratamientos.map((t) {
                                      return DropdownMenuItem<String>(
                                        value: t['id'].toString(),
                                        child: Text(
                                          t['nombre'] ?? 'Sin nombre',
                                          style: const TextStyle(
                                            color: Color(0xFF006064),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 30),

                        // Panel de grabación
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE0F2FE)),
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _toggleGrabacion,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: _isRecording
                                        ? Colors.redAccent
                                        : primaryCyan,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            (_isRecording
                                                    ? Colors.redAccent
                                                    : primaryCyan)
                                                .withValues(alpha: 0.3),
                                        blurRadius: _isRecording ? 20 : 10,
                                        spreadRadius: _isRecording ? 4 : 1,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isRecording
                                        ? Icons.stop
                                        : (_hasRecording
                                              ? Icons.check_circle
                                              : Icons.mic),
                                    color: Colors.white,
                                    size: 42,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _isRecording
                                    ? "Grabando... Presiona para detener"
                                    : _hasRecording
                                    ? "✅ Grabación lista"
                                    : "Presiona para grabar",
                                style: TextStyle(
                                  color: _isRecording
                                      ? Colors.redAccent
                                      : _hasRecording
                                      ? Colors.green
                                      : const Color(0xFF006064),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Campo de anotación / transcripción
                        const Text(
                          "Descripción / Transcripción",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF006064),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _notaController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText:
                                "Escribe aquí la transcripción o una nota adicional...",
                            hintStyle: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF0F9FF),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Color(0xFFBAE6FD),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Color(0xFFBAE6FD),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Color(0xFF00ACC1),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),

                        // Botón guardar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _guardarNota,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryCyan,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    "Guardar Nota",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // ── LISTA EN TIEMPO REAL ────────────────────────────
                  Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: supabase
                          .from('notavoz')
                          .stream(primaryKey: ['id'])
                          .order('fecha', ascending: false),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: primaryCyan),
                          );
                        }
                        final allNotas = snapshot.data ?? [];
                        final notas = allNotas.where((n) => userTratamientoIds.contains(n['tratamiento_id'].toString())).toList();

                        if (notas.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Text(
                                "No hay notas registradas aún.",
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Notas registradas",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006064),
                              ),
                            ),
                            const SizedBox(height: 15),
                            ...notas.map((n) => _notaCard(n, primaryCyan)),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _notaCard(Map<String, dynamic> n, Color primaryCyan) {
    String fecha = '';
    if (n['fecha'] != null) {
      try {
        final dt = DateTime.parse(n['fecha'].toString());
        fecha =
            "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      } catch (_) {}
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            //  SOLUCIÓN CORRECTA
            child: Icon(Icons.mic_rounded, color: primaryCyan, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n['url_audio'] ?? 'Sin descripción',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF006064),
                  ),
                ),
                if (fecha.isNotEmpty)
                  Text(
                    "🕐 $fecha",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
              size: 20,
            ),
            onPressed: () => _eliminarNota(n['id'].toString()),
          ),
        ],
      ),
    );
  }
}
