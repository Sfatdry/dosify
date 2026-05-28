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

  // Variables de Estado
  String _selectedEstado = 'Pendiente';
  List<dynamic> _tratamientosActivos = [];
  String? _tratamientoSeleccionadoId;
  
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  bool _isLoadingData = true;
  bool _isSaving = false;
  
  // Controladores de texto visuales
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarTratamientosDesdeSupabase();
  }

  // Carga los medicamentos de la tabla tratamiento para llenar el selector
  Future<void> _cargarTratamientosDesdeSupabase() async {
    try {
      setState(() => _isLoadingData = true);
      
      final List<dynamic> response = await supabase
          .from('tratamiento')
          .select('id, nombre')
          .order('nombre', ascending: true);

      setState(() {
        _tratamientosActivos = response;
        if (_tratamientosActivos.isNotEmpty) {
          _tratamientoSeleccionadoId = _tratamientosActivos.first['id'].toString();
        }
      });
    } catch (e) {
      debugPrint("Error cargando tratamientos en dosis: $e");
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  // Lógica para estructurar los datos y subirlos a Supabase
  Future<void> _guardarDosisEnBaseDeDatos() async {
    if (_tratamientoSeleccionadoId == null || _fechaSeleccionada == null || _horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Unimos la fecha y hora nativas en un solo objeto DateTime compatible con Supabase
      final DateTime fechaHoraFinal = DateTime(
        _fechaSeleccionada!.year,
        _fechaSeleccionada!.month,
        _fechaSeleccionada!.day,
        _horaSeleccionada!.hour,
        _horaSeleccionada!.minute,
      );

      final String dosisId = _uuidGenerator.v4();

      // Mapeo exacto según las columnas de tu BD: id, medicamento_id, fecha_hora, estado
      final mapDosis = {
        'id': dosisId,
        'medicamento_id': _tratamientoSeleccionadoId,
        'fecha_hora': fechaHoraFinal.toIso8601String(),
        'estado': _selectedEstado,
      };

      await supabase.from('dosis').insert(mapDosis);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Dosis guardada con éxito!"), 
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Limpieza de campos en la misma interfaz (Sin pantallas en blanco)
        setState(() {
          _fechaController.clear();
          _horaController.clear();
          _fechaSeleccionada = null;
          _horaSeleccionada = null;
          _selectedEstado = 'Pendiente';
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
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator(color: primaryCyan))
          : SingleChildScrollView(
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
                      // 1. ENCABEZADO DE LA TARJETA
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

                      // NUEVO CAMPO: SELECCIÓN DE MEDICAMENTO REAL
                      const Text(
                        "Medicamento / Tratamiento", 
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064), fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      _tratamientosActivos.isEmpty
                          ? const Text("No tienes tratamientos creados todavía.", style: TextStyle(color: Colors.red, fontSize: 13))
                          : DropdownButtonFormField<String>(
                              value: _tratamientoSeleccionadoId,
                              dropdownColor: Colors.white,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.medical_services_outlined, color: primaryCyan, size: 20),
                                filled: true,
                                fillColor: const Color(0xFFF0F9FF),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                              ),
                              items: _tratamientosActivos.map((t) {
                                return DropdownMenuItem<String>(
                                  value: t['id'].toString(),
                                  child: Text(t['nombre'] ?? 'Sin nombre'),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _tratamientoSeleccionadoId = value),
                            ),
                      const SizedBox(height: 24),

                      // 2. CAMPO: FECHA PROGRAMADA
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

                      // 3. CAMPO: HORA PROGRAMADA
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

                      // 4. SECCIÓN: ESTADO (Selector Grid de 2x2)
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
                          _buildEstadoButton("Pendiente", const Color(0xFFE0F2FE), const Color(0xFF0369A1)),
                          _buildEstadoButton("Tomada", const Color(0xFFDCFCE7), const Color(0xFF15803D)),
                          _buildEstadoButton("Omitida", const Color(0xFFFEE2E2), const Color(0xFFB91C1C)),
                          _buildEstadoButton("Tarde", const Color(0xFFFEF3C7), const Color(0xFFB45309)),
                        ],
                      ),
                      const SizedBox(height: 35),

                      // 5. BOTÓN DE GUARDAR ACCIÓN CONECTADO A SUPABASE
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving || _tratamientosActivos.isEmpty ? null : _guardarDosisEnBaseDeDatos,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryCyan,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
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
    );
  }

  Widget _buildEstadoButton(String estado, Color activeBgColor, Color activeTextColor) {
    bool isSelected = _selectedEstado == estado;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEstado = estado;
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
          estado,
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