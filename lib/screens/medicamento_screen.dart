import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class MedicamentoScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const MedicamentoScreen({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  State<MedicamentoScreen> createState() => _MedicamentoScreenState();
}

class _MedicamentoScreenState extends State<MedicamentoScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final Uuid _uuidGenerator = const Uuid();

  bool _isCritico = false;
  bool _isSaving = false;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _dosisController = TextEditingController();
  final TextEditingController _frecuenciaController = TextEditingController();
  final TextEditingController _duracionController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  String? _selectedMedId;

  Future<void> _guardarMedicamento() async {
    if (_nombreController.text.trim().isEmpty ||
        _dosisController.text.trim().isEmpty ||
        _frecuenciaController.text.trim().isEmpty ||
        _duracionController.text.trim().isEmpty ||
        _stockController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, completa todos los campos"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final String userId = widget.userId;

    setState(() => _isSaving = true);

    try {
      // 1. Obtener o crear tratamiento principal para vincular el medicamento
      final List<dynamic> datos = await supabase
          .from('tratamiento')
          .select()
          .eq('usuario_id', userId);

      String tId;
      if (datos.isEmpty) {
        final nuevo = await supabase
            .from('tratamiento')
            .insert({
              'usuario_id': userId,
              'nombre': 'Tratamiento Principal',
              'estado': 'Activo',
              'fecha_inicio': DateTime.now().toIso8601String().split('T').first,
              'fecha_fin': DateTime.now()
                  .add(const Duration(days: 30))
                  .toIso8601String()
                  .split('T')
                  .first,
            })
            .select()
            .single();
        tId = nuevo['id'].toString();
      } else {
        tId = datos[0]['id'].toString();
      }

      final String nuevoId = _uuidGenerator.v4();
      final mapMedicamento = {
        'id': nuevoId,
        'nombre': _nombreController.text.trim(),
        'dosis': _dosisController.text.trim(),
        'frecuencia_horas':
            int.tryParse(_frecuenciaController.text.trim()) ?? 8,
        'duracion_dias': int.tryParse(_duracionController.text.trim()) ?? 7,
        'es_critico': _isCritico,
        'tratamiento_id': tId,
        'created_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('medicamento').insert(mapMedicamento);

      final int stock = int.tryParse(_stockController.text.trim()) ?? 30;
      final mapInventario = {
        'medicamento_id': nuevoId,
        'cantidad_inicial': stock,
        'cantidad_actual': stock,
        'alerta_minima': 5,
      };

      await supabase.from('inventario').insert(mapInventario);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Medicamento guardado e Indexado en Inventario!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        _limpiarFormulario();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _eliminarMedicamento(String id) async {
    try {
      await supabase.from('dosis').delete().eq('medicamento_id', id);
      await supabase.from('inventario').delete().eq('medicamento_id', id);
      await supabase.from('medicamento').delete().eq('id', id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Medicamento eliminado de la base de datos"),
            backgroundColor: Colors.blueGrey,
          ),
        );
        if (_selectedMedId == id) {
          setState(() => _selectedMedId = null);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No se pudo eliminar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _dosisController.clear();
    _frecuenciaController.clear();
    _duracionController.clear();
    _stockController.clear();
    setState(() {
      _isCritico = false;
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _dosisController.dispose();
    _frecuenciaController.dispose();
    _duracionController.dispose();
    _stockController.dispose();
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

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase
                .from('medicamento')
                .stream(primaryKey: ['id'])
                .order('nombre', ascending: true),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryCyan),
                );
              }

              final allMedicamentos = snapshot.data ?? [];
              final medicamentos = allMedicamentos
                  .where(
                    (m) => userTratamientoIds.contains(
                      m['tratamiento_id'].toString(),
                    ),
                  )
                  .toList();

              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase.from('inventario').stream(primaryKey: ['id']),
                builder: (context, invSnapshot) {
                  if (invSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryCyan),
                    );
                  }

                  final inventarios = invSnapshot.data ?? [];
                  final Map<String, Map<String, dynamic>> inventarioMap = {
                    for (var inv in inventarios)
                      inv['medicamento_id'].toString(): inv,
                  };

                  final listaIds = medicamentos
                      .map((m) => m['id'].toString())
                      .toList();
                  if (_selectedMedId == null ||
                      !listaIds.contains(_selectedMedId)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && medicamentos.isNotEmpty) {
                        setState(
                          () => _selectedMedId = medicamentos.first['id']
                              .toString(),
                        );
                      }
                    });
                  }

                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1. CAROUSEL DINÁMICO
                          medicamentos.isEmpty
                              ? Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 550,
                                  ),
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(25),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "No hay medicamentos agregados todavía.",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 900,
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: medicamentos.map((med) {
                                        final String id = med['id'].toString();
                                        final String nombre =
                                            med['nombre'] ?? 'Sin nombre';
                                        final String dosis = med['dosis'] ?? '';
                                        final String frecuencia =
                                            "Cada ${med['frecuencia_horas'] ?? 8}h";

                                        final inv = inventarioMap[id];
                                        final int stockActual =
                                            inv?['cantidad_actual'] ?? 30;
                                        final String stockContenido =
                                            "$stockActual Unidades";
                                        final bool esCritico =
                                            med['es_critico'] == true;

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 20,
                                          ),
                                          child: _buildMedOverviewCard(
                                            id,
                                            nombre,
                                            dosis,
                                            frecuencia,
                                            stockContenido,
                                            primaryCyan,
                                            esCritico,
                                            isSelected: _selectedMedId == id,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 40),

                          // 2. FORMULARIO DE DETALLES
                          Container(
                            constraints: const BoxConstraints(maxWidth: 550),
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: const Icon(
                                        Icons.display_settings,
                                        color: primaryCyan,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          "Detalles del Medicamento",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF006064),
                                          ),
                                        ),
                                        Text(
                                          "Configuración y dosificación",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 35),

                                _buildLabel("Nombre del medicamento"),
                                _buildTextField(
                                  _nombreController,
                                  Icons.medication_outlined,
                                  primaryCyan,
                                  "Ej: Amoxicilina",
                                  TextInputType.text,
                                ),
                                const SizedBox(height: 25),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel("Dosis (ej: 500mg)"),
                                          _buildTextField(
                                            _dosisController,
                                            Icons.blur_on,
                                            primaryCyan,
                                            "Ej: 1 tableta",
                                            TextInputType.text,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel(
                                            "Pastillas por caja (Stock)",
                                          ),
                                          _buildTextField(
                                            _stockController,
                                            Icons.inventory,
                                            primaryCyan,
                                            "Ej: 30",
                                            TextInputType.number,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 25),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel("Frecuencia (horas)"),
                                          _buildTextField(
                                            _frecuenciaController,
                                            Icons.access_time,
                                            primaryCyan,
                                            "Ej: 8",
                                            TextInputType.number,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel("Duración (días)"),
                                          _buildTextField(
                                            _duracionController,
                                            Icons.calendar_today_outlined,
                                            primaryCyan,
                                            "Ej: 7",
                                            TextInputType.number,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),

                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _isCritico = !_isCritico),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F9FF),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: const Color(0xFFE0F2FE),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: _isCritico,
                                          activeColor: Colors.orange,
                                          onChanged: (val) => setState(
                                            () => _isCritico = val ?? false,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              "Medicamento crítico",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF006064),
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              "Requiere adherencia estricta",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 35),

                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: ElevatedButton(
                                        onPressed: _isSaving
                                            ? null
                                            : _guardarMedicamento,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryCyan,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 18,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                        ),
                                        child: _isSaving
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Text(
                                                "Guardar Medicamento",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      flex: 1,
                                      child: OutlinedButton(
                                        onPressed: _limpiarFormulario,
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFF1F5F9,
                                          ),
                                          side: BorderSide.none,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 18,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          "Limpiar",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF006064),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    IconData? prefixIcon,
    Color activeColor,
    String hint,
    TextInputType type,
  ) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: activeColor, size: 20)
            : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: activeColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildMedOverviewCard(
    String id,
    String name,
    String mg,
    String freq,
    String units,
    Color iconColor,
    bool isCritico, {
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedMedId = id),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFF00ACC1) : Colors.transparent,
            width: 2,
          ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: iconColor.withOpacity(0.1),
                  child: Icon(Icons.medication, color: iconColor, size: 20),
                ),
                Row(
                  children: [
                    if (isCritico)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4E6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.bolt, color: Colors.pink, size: 12),
                            SizedBox(width: 4),
                            Text(
                              "Crítico",
                              style: TextStyle(
                                color: Colors.pink,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      onPressed: () => _showDeleteConfirmation(id, name),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006064),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 15),
            _rowItem(Icons.blur_on, mg),
            _rowItem(Icons.access_time, freq),
            _rowItem(Icons.inventory, units),
          ],
        ),
      ),
    );
  }

  Widget _rowItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 18),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String id, String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Eliminar Medicamento"),
          content: Text(
            "¿Estás seguro de eliminar '$name'? Se borrará de forma permanente de tu Supabase.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _eliminarMedicamento(id);
              },
              child: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
