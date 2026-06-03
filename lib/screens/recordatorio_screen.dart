import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecordatorioScreen extends StatefulWidget {
  final String userName;

  const RecordatorioScreen({super.key, required this.userName});

  @override
  State<RecordatorioScreen> createState() => _RecordatorioScreenState();
}

class _RecordatorioScreenState extends State<RecordatorioScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _tratamientoId; 

  bool isCritica = false;
  bool isRecordatorioActivo = true; 
  final TextEditingController _repeticionesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatosRecordatorio();
  }

  @override
  void dispose() {
    _repeticionesController.dispose();
    super.dispose();
  }

  // --- OBTENER CONFIGURACIÓN DESDE SUPABASE ---
  Future<void> _cargarDatosRecordatorio() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Consultamos usando los nombres de columnas exactos de tu base de datos
      final List<dynamic> tratamientos = await supabase
          .from('tratamiento')
          .select('id, tipo_alerta, repeticiones, recordatorio_activo')
          .limit(1);

      if (tratamientos.isNotEmpty) {
        final data = tratamientos.first;
        _tratamientoId = data['id']; 
        
        // Comparamos en mayúsculas tal cual se ve en tu captura (NORMAL / CRÍTICA)
        final String tipoAlerta = (data['tipo_alerta'] ?? 'NORMAL').toString().toUpperCase();
        isCritica = tipoAlerta == 'CRÍTICA' || tipoAlerta == 'CRITICA';
        
        _repeticionesController.text = (data['repeticiones'] ?? 1).toString();
        isRecordatorioActivo = data['recordatorio_activo'] ?? true; 
      } else {
        _tratamientoId = null;
        isCritica = false;
        isRecordatorioActivo = true;
        _repeticionesController.text = "1";
      }
      
    } catch (e) {
      print("Error al cargar recordatorio: $e");
      _repeticionesController.text = "1";
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- GUARDAR ACTUALIZACIÓN EN SUPABASE ---
  Future<void> _guardarRecordatorio() async {
    final int? repeticiones = int.tryParse(_repeticionesController.text);
    if (repeticiones == null || repeticiones <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, introduce un número de repeticiones válido.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Mapeo exacto con los nombres de la base de datos de tus capturas
      final datosAEnviar = {
        'tipo_alerta': isCritica ? 'CRÍTICA' : 'NORMAL',
        'repeticiones': repeticiones,
        'recordatorio_activo': isRecordatorioActivo, 
      };

      if (_tratamientoId != null) {
        await supabase
            .from('tratamiento')
            .update(datosAEnviar)
            .eq('id', _tratamientoId!);
      } else {
        // En caso de insertar un registro nuevo si estuviera vacío
        await supabase
            .from('tratamiento')
            .insert(datosAEnviar);
      }

      await _cargarDatosRecordatorio();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Configuración guardada con éxito! 🎉"),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      print("Error al guardar en Supabase: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al guardar en la BD: $e"), 
          backgroundColor: Colors.redAccent
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryCyan))
          : RefreshIndicator(
              onRefresh: _cargarDatosRecordatorio,
              color: primaryCyan,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(25),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              )
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
                                    child: const Icon(Icons.notifications_active, color: primaryCyan, size: 28),
                                  ),
                                  const SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Configurar Alertas",
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                      ),
                                      Text(
                                        "Hola ${widget.userName}, gestiona tus avisos",
                                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),

                              const Text(
                                "Tipo de Alerta",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF475569)),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: _buildAlertOption("Normal", Icons.notifications_none, !isCritica)),
                                  const SizedBox(width: 15),
                                  Expanded(child: _buildAlertOption("Crítica", Icons.warning_amber_rounded, isCritica)),
                                ],
                              ),
                              const SizedBox(height: 25),

                              const Text(
                                "Número de Repeticiones",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF475569)),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _repeticionesController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  hintText: "Ej. 3",
                                  prefixIcon: const Icon(Icons.replay, color: primaryCyan),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.grey.shade200),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.grey.shade200),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F9FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE0F2FE)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.toggle_on_outlined, color: Color(0xFF0284C7)),
                                        SizedBox(width: 12),
                                        Text(
                                          "¿Recordatorio activo?",
                                          style: TextStyle(color: Color(0xFF0369A1), fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      value: isRecordatorioActivo,
                                      activeColor: primaryCyan,
                                      onChanged: (val) => setState(() => isRecordatorioActivo = val),
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
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    "Guardar Configuración",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
        padding: const EdgeInsets.symmetric(vertical: 16),
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
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}