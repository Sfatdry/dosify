import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

class RecordatorioScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const RecordatorioScreen({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  State<RecordatorioScreen> createState() => _RecordatorioScreenState();
}

class _RecordatorioScreenState extends State<RecordatorioScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _recordatorioId;
  String? _medicamentoId; // Necesario para asociar el recordatorio
  List<Map<String, dynamic>> _userMedicamentos = [];

  bool isCritica = false;
  bool isRecordatorioActivo = true;
  final TextEditingController _repeticionesController = TextEditingController();

  TimeOfDay _horaSeleccionada = const TimeOfDay(hour: 7, minute: 53);

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    _repeticionesController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00ACC1),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _horaSeleccionada) {
      setState(() {
        _horaSeleccionada = picked;
      });
    }
  }

  Future<void> _cargarDatosIniciales() async {
    try {
      setState(() => _isLoading = true);

      // 1. Obtener tratamientos del usuario
      final treatments = await supabase
          .from('tratamiento')
          .select('id')
          .eq('usuario_id', widget.userId);
      final treatmentIds = treatments.map((t) => t['id'].toString()).toList();

      if (treatmentIds.isNotEmpty) {
        // 2. Obtener medicamentos de esos tratamientos
        final meds = await supabase
            .from('medicamento')
            .select(
              'id, nombre, tratamiento_id, tratamiento(tipo_alerta, repeticiones)',
            )
            .inFilter('tratamiento_id', treatmentIds)
            .order('nombre', ascending: true);

        _userMedicamentos = List<Map<String, dynamic>>.from(meds);

        if (_userMedicamentos.isNotEmpty) {
          final listIds = _userMedicamentos
              .map((m) => m['id'].toString())
              .toList();
          if (_medicamentoId == null || !listIds.contains(_medicamentoId)) {
            _medicamentoId = listIds.first;
          }

          final selectedMed = _userMedicamentos.firstWhere(
            (m) => m['id'].toString() == _medicamentoId,
          );
          final tratamientoData = selectedMed['tratamiento'];
          if (tratamientoData != null) {
            _repeticionesController.text =
                (tratamientoData['repeticiones'] ?? 1).toString();
            final String tipoAlerta =
                (tratamientoData['tipo_alerta'] ?? 'NORMAL')
                    .toString()
                    .toUpperCase();
            isCritica = tipoAlerta == 'CRÍTICA' || tipoAlerta == 'CRITICA';
          }

          // 3. Buscar si este medicamento ya tiene un recordatorio
          final recordatorios = await supabase
              .from('recordatorio')
              .select('id, fecha_hora, activo')
              .eq('medicamento_id', _medicamentoId!)
              .limit(1);

          if (recordatorios.isNotEmpty) {
            final rec = recordatorios.first;
            _recordatorioId = rec['id'];
            isRecordatorioActivo = rec['activo'] ?? true;

            if (rec['fecha_hora'] != null) {
              final DateTime dt = DateTime.parse(rec['fecha_hora']);
              _horaSeleccionada = TimeOfDay(hour: dt.hour, minute: dt.minute);
            }
          } else {
            _recordatorioId = null;
            isRecordatorioActivo = true;
            _horaSeleccionada = const TimeOfDay(hour: 8, minute: 0);
          }
        } else {
          _medicamentoId = null;
          _recordatorioId = null;
        }
      } else {
        _userMedicamentos = [];
        _medicamentoId = null;
        _recordatorioId = null;
      }
    } catch (e) {
      print("Error al cargar datos: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _guardarRecordatorio() async {
    if (_medicamentoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No se encontró un medicamento válido para asignar el recordatorio.",
          ),
        ),
      );
      return;
    }

    final int? repeticiones = int.tryParse(_repeticionesController.text);
    if (repeticiones == null || repeticiones <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Por favor, introduce un número de repeticiones válido.",
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ahora = DateTime.now();
      final fechaHoraRecordatorio = DateTime(
        ahora.year,
        ahora.month,
        ahora.day,
        _horaSeleccionada.hour,
        _horaSeleccionada.minute,
      ).toIso8601String();

      // 1. Guardamos en la tabla 'recordatorio' con sus campos reales
      final datosRecordatorio = {
        'medicamento_id': _medicamentoId,
        'fecha_hora': fechaHoraRecordatorio,
        'activo': isRecordatorioActivo,
      };

      if (_recordatorioId != null) {
        await supabase
            .from('recordatorio')
            .update(datosRecordatorio)
            .eq('id', _recordatorioId!);
      } else {
        await supabase.from('recordatorio').insert(datosRecordatorio);
      }

      // 2. Opcional: Actualizamos también la tabla 'tratamiento' si deseas mantener los datos sincronizados
      final List<dynamic> medAsociado = await supabase
          .from('medicamento')
          .select('tratamiento_id')
          .eq('id', _medicamentoId!)
          .limit(1);

      if (medAsociado.isNotEmpty &&
          medAsociado.first['tratamiento_id'] != null) {
        final String tratamientoId = medAsociado.first['tratamiento_id'];
        await supabase
            .from('tratamiento')
            .update({
              'tipo_alerta': isCritica ? 'CRÍTICA' : 'NORMAL',
              'repeticiones': repeticiones,
              'recordatorio_activo': isRecordatorioActivo,
            })
            .eq('id', tratamientoId);
      }

      await _cargarDatosIniciales();
    await _playNotificationSound();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "¡Recordatorio guardado con éxito en la tabla correspondiente! 🎉",
            ),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      print("Error al guardar en Supabase: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar en la BD: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Play a notification sound using audioplayers
  Future<void> _playNotificationSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('assets/sounds/notification.wav'));
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);

    final ahora = DateTime.now();
    final dtHora = DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
      _horaSeleccionada.hour,
      _horaSeleccionada.minute,
    );
    final String horaFormateada = DateFormat('hh:mm a').format(dtHora);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryCyan))
          : RefreshIndicator(
              onRefresh: _cargarDatosIniciales,
              color: primaryCyan,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(25),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 650),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(35),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F7FA),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.notifications_active,
                                      color: primaryCyan,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Configurar Alertas",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      Text(
                                        "Hola ${widget.userName}, gestiona tus avisos",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Text(
                                "Seleccionar Medicamento",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _userMedicamentos.isEmpty
                                  ? const Text(
                                      "Crea un medicamento primero",
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
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: _medicamentoId,
                                          onChanged: (val) {
                                            setState(() {
                                              _medicamentoId = val;
                                              _recordatorioId =
                                                  null; // reset to check for new medicine
                                            });
                                            _cargarDatosIniciales();
                                          },
                                          items: _userMedicamentos.map((med) {
                                            return DropdownMenuItem<String>(
                                              value: med['id'].toString(),
                                              child: Text(
                                                med['nombre'] ?? 'Sin nombre',
                                                style: const TextStyle(
                                                  color: Color(0xFF1E293B),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                              const SizedBox(height: 25),

                              const Text(
                                "Hora del Recordatorio",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () => _seleccionarHora(context),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time_filled,
                                            color: primaryCyan,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            horaFormateada,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Text(
                                        "Cambiar hora",
                                        style: TextStyle(
                                          color: primaryCyan,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),

                              const Text(
                                "Tipo de Alerta",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildAlertOption(
                                      "Normal",
                                      Icons.notifications_none,
                                      !isCritica,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: _buildAlertOption(
                                      "Crítica",
                                      Icons.warning_amber_rounded,
                                      isCritica,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 25),

                              const Text(
                                "Número de Repeticiones",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _repeticionesController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Ej. 5",
                                  prefixIcon: const Icon(
                                    Icons.replay,
                                    color: primaryCyan,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F9FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE0F2FE),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.toggle_on_outlined,
                                          color: Color(0xFF0284C7),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          "¿Recordatorio activo?",
                                          style: TextStyle(
                                            color: Color(0xFF0369A1),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      value: isRecordatorioActivo,
                                      activeThumbColor: primaryCyan,
                                      onChanged: (val) => setState(
                                        () => isRecordatorioActivo = val,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 35),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _guardarRecordatorio,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryCyan,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    "Guardar Configuración",
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildAlertOption(String label, IconData icon, bool isSelected) {
    const Color primaryCyan = Color(0xFF00ACC1);
    return GestureDetector(
      onTap: () => setState(() => isCritica = label == "Crítica"),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F7FA) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryCyan : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? primaryCyan : Colors.grey, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primaryCyan : const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
