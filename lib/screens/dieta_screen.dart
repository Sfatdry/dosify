import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DietaScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const DietaScreen({super.key, required this.userName, required this.userId});

  @override
  State<DietaScreen> createState() => _DietaScreenState();
}

class _DietaScreenState extends State<DietaScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();

  bool _isSaving = false;
  DateTime? _fechaInicioRaw;
  DateTime? _fechaFinRaw;

  // Tratamiento seleccionado
  String? _tratamientoSeleccionadoId;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(
    BuildContext ctx,
    TextEditingController ctrl,
    bool isInicio,
  ) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF00ACC1)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        ctrl.text = DateFormat('dd/MM/yyyy').format(picked);
        if (isInicio) {
          _fechaInicioRaw = picked;
        } else {
          _fechaFinRaw = picked;
        }
      });
    }
  }

  Future<void> _guardarDieta() async {
    if (_descripcionController.text.trim().isEmpty) {
      _snack("Por favor ingresa una descripción", Colors.orange);
      return;
    }
    if (_tratamientoSeleccionadoId == null) {
      _snack("Selecciona un tratamiento asociado", Colors.orange);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await supabase.from('dieta').insert({
        'usuario_id': widget.userId,
        'tratamiento_id': _tratamientoSeleccionadoId,
        'descripcion': _descripcionController.text.trim(),
        'fecha_inicio': _fechaInicioRaw?.toIso8601String().split('T').first,
        'fecha_fin': _fechaFinRaw?.toIso8601String().split('T').first,
      });

      if (mounted) {
        _snack("Dieta guardada correctamente ✅", Colors.green);
        _descripcionController.clear();
        _fechaInicioController.clear();
        _fechaFinController.clear();
        setState(() {
          _fechaInicioRaw = null;
          _fechaFinRaw = null;
          _tratamientoSeleccionadoId = null;
        });
      }
    } catch (e) {
      if (mounted) _snack("Error al guardar: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Future<void> _eliminarDieta(String id) async {
    try {
      await supabase.from('dieta').delete().eq('id', id);
    } catch (e) {
      if (mounted) _snack("Error al eliminar: $e", Colors.red);
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);
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

          return Center(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
              child: Column(
                children: [
                  // ── FORMULARIO ────────────────────────────────────────
                  Container(
                    constraints: const BoxConstraints(maxWidth: 550),
                    padding: const EdgeInsets.all(35),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
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
                                Icons.restaurant_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Text(
                              "Dieta",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006064),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),

                        // Selector de tratamiento
                        _buildLabel("Tratamiento asociado"),
                        userTratamientos.isEmpty
                            ? const Text(
                                "Crea un tratamiento primero",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
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
                                    items: userTratamientos.map((t) {
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
                        const SizedBox(height: 25),

                        // Descripción
                        _buildLabel("Descripción"),
                        TextField(
                          controller: _descripcionController,
                          maxLines: 5,
                          decoration: _inputStyle(
                            "Describe la dieta recomendada...",
                            null,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Fecha inicio
                        _buildLabel("Fecha de Inicio"),
                        TextField(
                          controller: _fechaInicioController,
                          readOnly: true,
                          onTap: () => _selectDate(
                            context,
                            _fechaInicioController,
                            true,
                          ),
                          decoration: _inputStyle(
                            "dd/mm/aaaa",
                            Icons.calendar_today_outlined,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Fecha fin
                        _buildLabel("Fecha de Fin"),
                        TextField(
                          controller: _fechaFinController,
                          readOnly: true,
                          onTap: () =>
                              _selectDate(context, _fechaFinController, false),
                          decoration: _inputStyle(
                            "dd/mm/aaaa",
                            Icons.calendar_today_outlined,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Botón guardar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _guardarDieta,
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
                                    "Guardar Dieta",
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
                    constraints: const BoxConstraints(maxWidth: 550),
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: supabase
                          .from('dieta')
                          .stream(primaryKey: ['id'])
                          .eq('usuario_id', currentUserId)
                          .order('fecha_inicio', ascending: false),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: primaryCyan,
                            ),
                          );
                        }
                        final allDietas = snapshot.data ?? [];
                        final dietas = allDietas
                            .where(
                              (d) => userTratamientoIds.contains(
                                d['tratamiento_id'].toString(),
                              ),
                            )
                            .toList();

                        if (dietas.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Text(
                                "No hay dietas registradas aún.",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Dietas registradas",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006064),
                              ),
                            ),
                            const SizedBox(height: 15),
                            ...dietas.map((d) => _dietaCard(d, primaryCyan)),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _dietaCard(Map<String, dynamic> d, Color primaryCyan) {
    final inicio = d['fecha_inicio'] ?? '';
    final fin = d['fecha_fin'] ?? '';
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
            child: Icon(Icons.restaurant_rounded, color: primaryCyan, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d['descripcion'] ?? 'Sin descripción',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF006064),
                  ),
                ),
                if (inicio.isNotEmpty || fin.isNotEmpty)
                  Text(
                    '📅 $inicio${fin.isNotEmpty ? " → $fin" : ""}',
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
            onPressed: () => _eliminarDieta(d['id'].toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF006064),
          fontSize: 15,
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      suffixIcon: icon != null
          ? Icon(icon, color: const Color(0xFFBAE6FD), size: 20)
          : null,
      filled: true,
      fillColor: const Color(0xFFF0F9FF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFBAE6FD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFBAE6FD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF00ACC1), width: 1.5),
      ),
    );
  }
}
