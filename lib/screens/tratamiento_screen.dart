import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class TratamientoScreen extends StatefulWidget {
  final String? userName;
  final String userId;
  const TratamientoScreen({super.key, this.userName, required this.userId});

  @override
  State<TratamientoScreen> createState() => _TratamientoScreenState();
}

class _TratamientoScreenState extends State<TratamientoScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final Uuid _uuidGenerator = const Uuid();
  final TextEditingController _nombreController = TextEditingController();

  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  String _estadoSeleccionado = 'Activo';

  bool _isLoadingUser = true;
  bool _isSaving = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _obtenerUsuarioActivo();
  }

  Future<void> _obtenerUsuarioActivo() async {
    _currentUserId = widget.userId;
    if (mounted) {
      setState(() => _isLoadingUser = false);
    }
  }

  Future<void> _seleccionarFecha(
    BuildContext context,
    bool esFechaInicio,
  ) async {
    final DateTime hoy = DateTime.now();
    final DateTime? seleccionado = await showDatePicker(
      context: context,
      initialDate: esFechaInicio
          ? (_fechaInicio ?? hoy)
          : (_fechaFin ?? _fechaInicio ?? hoy),
      firstDate: esFechaInicio ? hoy : (_fechaInicio ?? hoy),
      lastDate: DateTime(hoy.year + 5),
    );

    if (seleccionado != null) {
      setState(() {
        if (esFechaInicio) {
          _fechaInicio = seleccionado;
          if (_fechaFin != null && _fechaFin!.isBefore(_fechaInicio!)) {
            _fechaFin = null;
          }
        } else {
          _fechaFin = seleccionado;
        }
      });
    }
  }

  Future<void> _guardarTratamiento() async {
    if (_nombreController.text.trim().isEmpty ||
        _fechaInicio == null ||
        _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, llena todos los campos"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final String tratamientoId = _uuidGenerator.v4();
      final mapTratamiento = {
        'id': tratamientoId,
        'usuario_id': _currentUserId ?? supabase.auth.currentUser?.id,
        'nombre': _nombreController.text.trim(),
        'fecha_inicio': DateFormat('yyyy-MM-dd').format(_fechaInicio!),
        'fecha_fin': DateFormat('yyyy-MM-dd').format(_fechaFin!),
        'estado': _estadoSeleccionado,
      };

      await supabase.from('tratamiento').insert(mapTratamiento);

      if (mounted) {
        // 🚨 CAMBIO CLAVE: Mensaje de éxito en la misma interfaz
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tratamiento guardado con éxito"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Limpiamos los controles para que pueda registrar otro si quiere sin salirse
        setState(() {
          _nombreController.clear();
          _fechaInicio = null;
          _fechaFin = null;
          _estadoSeleccionado = 'Activo';
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $error"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);
    const Color textCyan = Color(0xFF006064);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.of(
            context,
          ).pop(true), // Regresa avisando que puede haber cambios
        ),
      ),
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator(color: primaryCyan))
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Container(
                    padding: const EdgeInsets.all(35),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryCyan.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.assignment_outlined,
                              color: primaryCyan,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Center(
                          child: Text(
                            "Tratamiento",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: textCyan,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        const Text(
                          "Nombre del tratamiento",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textCyan,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nombreController,
                          decoration: InputDecoration(
                            hintText: "Ej. Paracetamol 500mg",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.medical_services_outlined,
                              color: primaryCyan,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: primaryCyan,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "Fecha de Inicio",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textCyan,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDatePickerButton(
                          texto: _fechaInicio == null
                              ? "dd/mm/aaaa"
                              : DateFormat(
                                  'dd / MM / yyyy',
                                ).format(_fechaInicio!),
                          icon: Icons.calendar_today_rounded,
                          color: primaryCyan,
                          onTap: () => _seleccionarFecha(context, true),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "Fecha de Fin",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textCyan,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDatePickerButton(
                          texto: _fechaFin == null
                              ? "dd/mm/aaaa"
                              : DateFormat('dd / MM / yyyy').format(_fechaFin!),
                          icon: Icons.calendar_month_rounded,
                          color: primaryCyan,
                          onTap: _fechaInicio == null
                              ? null
                              : () => _seleccionarFecha(context, false),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "Estado del tratamiento",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textCyan,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _estadoSeleccionado,
                          dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.info_outline_rounded,
                              color: primaryCyan,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: primaryCyan,
                                width: 2,
                              ),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Activo',
                              child: Text('Activo'),
                            ),
                            DropdownMenuItem(
                              value: 'Completado',
                              child: Text('Completado'),
                            ),
                            DropdownMenuItem(
                              value: 'Pausado',
                              child: Text('Pausado'),
                            ),
                            DropdownMenuItem(
                              value: 'Cancelado',
                              child: Text('Cancelado'),
                            ),
                          ],
                          onChanged: (String? nuevoValor) {
                            if (nuevoValor != null)
                              setState(() => _estadoSeleccionado = nuevoValor);
                          },
                        ),
                        const SizedBox(height: 35),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _guardarTratamiento,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryCyan,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSaving
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Guardar Tratamiento",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
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

  Widget _buildDatePickerButton({
    required String texto,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: onTap == null ? Colors.grey.shade400 : color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              texto,
              style: TextStyle(
                color: onTap == null ? Colors.grey.shade400 : Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
