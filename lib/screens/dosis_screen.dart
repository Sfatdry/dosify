import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class DosisScreen extends StatefulWidget {
  final String userName;

  const DosisScreen({super.key, required this.userName});

  @override
  State<DosisScreen> createState() => _DosisScreenState();
}

class _DosisScreenState extends State<DosisScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final Uuid _uuidGenerator = const Uuid();

  // Estado del botón seleccionado (en minúsculas por el CHECK constraint)
  String _selectedEstado = 'pendiente';
  
  List<dynamic> _medicamentosDisponibles = [];
  String? _medicamentoSeleccionadoId;
  
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  bool _isLoadingData = true;
  bool _isSaving = false;
  
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarMedicamentosDesdeSupabase();
  }

  // Carga los medicamentos disponibles para el Dropdown
  Future<void> _cargarMedicamentosDesdeSupabase() async {
    try {
      setState(() => _isLoadingData = true);
      
      final List<dynamic> response = await supabase
          .from('medicamento')
          .select('id, nombre')
          .order('nombre', ascending: true);

      setState(() {
        _medicamentosDisponibles = response;
        if (_medicamentosDisponibles.isNotEmpty) {
          _medicamentoSeleccionadoId = _medicamentosDisponibles.first['id'].toString();
        } else {
          _medicamentoSeleccionadoId = null; // Limpia si no hay nada
        }
      });
    } catch (e) {
      debugPrint("Error cargando la lista de medicamentos: $e");
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  // FUNCIÓN PRINCIPAL PARA GUARDAR LA DOSIS
  Future<void> _guardarDosisEnBaseDeDatos() async {
    if (_medicamentoSeleccionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, selecciona un medicamento"), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_fechaSeleccionada == null || _horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, selecciona fecha y hora para la dosis"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Combinamos la fecha y hora seleccionada en un objeto DateTime final
      final DateTime fechaHoraFinal = DateTime(
        _fechaSeleccionada!.year,
        _fechaSeleccionada!.month,
        _fechaSeleccionada!.day,
        _horaSeleccionada!.hour,
        _horaSeleccionada!.minute,
      );

      final String dosisId = _uuidGenerator.v4();

      // Construcción del mapa respetando estrictamente los tipos de tu base de datos
      final mapDosis = {
        'id': dosisId,
        'medicamento_id': _medicamentoSeleccionadoId,
        'fecha_hora': fechaHoraFinal.toIso8601String(),
        'estado': _selectedEstado.toLowerCase().trim(), // Asegura minúsculas: 'tomada', 'pendiente', etc.
      };

      await supabase.from('dosis').insert(mapDosis);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Dosis registrada con éxito en la base de datos!"), 
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Resetear campos tras un guardado exitoso
        setState(() {
          _fechaController.clear();
          _horaController.clear();
          _fechaSeleccionada = null;
          _horaSeleccionada = null;
          _selectedEstado = 'pendiente';
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar: $error"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // --- MODIFICADO AQUÍ: Agregamos un indicador para deslizar y recargar ---
      body: RefreshIndicator(
        color: primaryCyan,
        onRefresh: _cargarMedicamentosDesdeSupabase, // Ejecuta la recarga al deslizar
        child: _isLoadingData
            ? const Center(child: CircularProgressIndicator(color: primaryCyan))
            : SingleChildScrollView(
                // Esto obliga a la pantalla a ser deslizable incluso si el contenido es corto
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.all(35),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03), 
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryCyan, 
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 15),
                            const Text(
                              "Registro de Dosis", 
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF006064)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),

                        const Text(
                          "Seleccionar Medicamento", 
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064), fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        
                        // --- MODIFICADO AQUÍ: Agregado botón de actualizar dinámico en caso de error ---
                        _medicamentosDisponibles.isEmpty
                            ? Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "No hay medicamentos en la tabla 'medicamento'. Agrega uno primero.", 
                                      style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500)
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh, color: primaryCyan),
                                    onPressed: _cargarMedicamentosDesdeSupabase,
                                    tooltip: "Actualizar lista",
                                  )
                                ],
                              )
                            : DropdownButtonFormField<String>(
                                value: _medicamentoSeleccionadoId,
                                dropdownColor: Colors.white,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.medical_services_outlined, color: primaryCyan, size: 20),
                                  filled: true,
                                  fillColor: const Color(0xFFF0F9FF),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                ),
                                items: _medicamentosDisponibles.map((m) {
                                  return DropdownMenuItem<String>(
                                    value: m['id'].toString(),
                                    child: Text(m['nombre'] ?? 'Sin nombre'),
                                  );
                                }).toList(),
                                onChanged: (value) => setState(() => _medicamentoSeleccionadoId = value),
                              ),
                        const SizedBox(height: 24),

                        const Text(
                          "Fecha Programada", 
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064), fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _fechaController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "dd/mm/aaaa",
                            prefixIcon: const Icon(Icons.calendar_today_outlined, color: primaryCyan, size: 20),
                            filled: true,
                            fillColor: const Color(0xFFF0F9FF),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2025),
                              lastDate: DateTime(2030),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _fechaSeleccionada = pickedDate;
                                _fechaController.text = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          "Hora Programada", 
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064), fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _horaController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "--:-- -----",
                            prefixIcon: const Icon(Icons.access_time, color: primaryCyan, size: 20),
                            filled: true,
                            fillColor: const Color(0xFFF0F9FF),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          ),
                          onTap: () async {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                _horaSeleccionada = pickedTime;
                                _horaController.text = pickedTime.format(context);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          "Estado", 
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064), fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 2.5,
                          children: [
                            _buildEstadoButton("pendiente", "Pendiente", const Color(0xFFE0F2FE), const Color(0xFF0369A1)),
                            _buildEstadoButton("tomada", "Tomada", const Color(0xFFDCFCE7), const Color(0xFF15803D)),
                            _buildEstadoButton("omitida", "Omitida", const Color(0xFFFEE2E2), const Color(0xFFB91C1C)),
                            _buildEstadoButton("tarde", "Tarde", const Color(0xFFFEF3C7), const Color(0xFFB45309)),
                          ],
                        ),
                        const SizedBox(height: 35),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving || _medicamentosDisponibles.isEmpty ? null : _guardarDosisEnBaseDeDatos,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryCyan,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text(
                                    "Guardar Estado", 
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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

  Widget _buildEstadoButton(String valorInterno, String textoVisual, Color activeBgColor, Color activeTextColor) {
    bool isSelected = _selectedEstado == valorInterno;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEstado = valorInterno;
        });
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? activeTextColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Text(
          textoVisual,
          style: TextStyle(
            color: isSelected ? activeTextColor : const Color(0xFF64748B),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}