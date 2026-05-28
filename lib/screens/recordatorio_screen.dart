import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecordatorioScreen extends StatefulWidget {
  final String userName;

  const RecordatorioScreen({super.key, required this.userName});

  @override
  State<RecordatorioScreen> createState() => _RecordatorioScreenState();
}

class _RecordatorioScreenState extends State<RecordatorioScreen> {
  // 1. Instancia del cliente de Supabase
  final SupabaseClient supabase = Supabase.instance.client;

  // Estados de control de carga
  bool _isLoading = true;
  String _errorMessage = '';
  String? _tratamientoId; // Guardará el ID del tratamiento a modificar

  // Variables de tu interfaz asignadas a los controles
  bool isCritica = false;
  bool isRecordatorioActivo = true;
  final TextEditingController _repeticionesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ejecutamos la carga inicial una vez renderizado el frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosRecordatorio();
    });
  }

  @override
  void dispose() {
    _repeticionesController.dispose();
    super.dispose();
  }

  // --- OBTENER CONFIGURACIÓN DESDE SUPABASE ---
  Future<void> _cargarDatosRecordatorio() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Validamos y esperamos la autenticación del usuario de forma segura
      var user = supabase.auth.currentUser;
      if (user == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        user = supabase.auth.currentUser;
      }

      if (user == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Usuario no autenticado. Por favor, inicia sesión.';
            _isLoading = false;
          });
        }
        return;
      }

      // Consultamos la tabla 'tratamiento' filtrando por el usuario autenticado
      // (Asegúrate de tener la relación de usuario_id o similar en tu tabla)
      final List<dynamic> tratamientos = await supabase
          .from('tratamiento')
          .select('id, tipo_alerta, repeticiones, recordatorio_activo')
          .limit(1);

      if (tratamientos.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = 'No se encontró un tratamiento activo para configurar recordatorios.';
            _isLoading = false;
          });
        }
        return;
      }

      final data = tratamientos.first;
      _tratamientoId = data['id']; // Almacenamos el ID para cuando guardemos

      if (mounted) {
        setState(() {
          // Mapeamos los campos de la BD a las variables de Flutter
          isCritica = data['tipo_alerta'] == 'Crítica';
          isRecordatorioActivo = data['recordatorio_activo'] ?? true;
          _repeticionesController.text = (data['repeticiones'] ?? 1).toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error al cargar recordatorio: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error de conexión con la base de datos.';
        });
      }
    }
  }

  // --- GUARDAR ACTUALIZACIÓN EN SUPABASE ---
  Future<void> _guardarRecordatorio() async {
    if (_tratamientoId == null) return;

    // Validación simple del input de texto numérico
    final int? repeticiones = int.tryParse(_repeticionesController.text);
    if (repeticiones == null || repeticiones <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, introduce un número de repeticiones válido.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Hacemos el UPDATE en la fila correspondiente al tratamiento actual
      await supabase.from('tratamiento').update({
        'tipo_alerta': isCritica ? 'Crítica' : 'Normal',
        'repeticiones': repeticiones,
        'recordatorio_activo': isRecordatorioActivo,
      }).eq('id', _tratamientoId!);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Recordatorio guardado en la base de datos! 🎉"),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      print("Error al guardar en Supabase: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar: $e"), 
            backgroundColor: Colors.redAccent
          ),
        );
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
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(_errorMessage, style: const TextStyle(color: Colors.grey, fontSize: 16), textAlign: TextAlign.center),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarDatosRecordatorio,
                  color: primaryCyan,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. ENCABEZADO
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: primaryCyan,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.notifications_none, color: Colors.white),
                                ),
                                const SizedBox(width: 15),
                                const Text(
                                  "Recordatorio",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006064)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // 2. SELECCIÓN DE TIPO DE ALERTA
                            const Text(
                              "Tipo de Alerta",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064)),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: _buildAlertOption("Normal", Icons.notifications_active_outlined, !isCritica)),
                                const SizedBox(width: 15),
                                Expanded(child: _buildAlertOption("Crítica", Icons.error_outline, isCritica)),
                              ],
                            ),
                            const SizedBox(height: 25),

                            // 3. CAMPO REPETICIONES
                            const Text(
                              "Repeticiones",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064)),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _repeticionesController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Número de repeticiones",
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                prefixIcon: const Icon(Icons.repeat, color: primaryCyan),
                                filled: true,
                                fillColor: const Color(0xFFF0F9FF),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 25),

                            // 4. BANNER RECORDATORIO ACTIVO (SWITCH)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F9FF),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: const Color(0xFFBAE6FD)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.notifications_none, color: primaryCyan),
                                      SizedBox(width: 10),
                                      Text(
                                        "Recordatorio activo",
                                        style: TextStyle(color: Color(0xFF0369A1), fontWeight: FontWeight.w500),
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

                            // 5. BOTÓN GUARDAR CONECTADO
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _guardarRecordatorio,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryCyan,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Text(
                                  "Guardar Recordatorio",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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

  Widget _buildAlertOption(String label, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => isCritica = label == "Crítica"),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F7FA) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? const Color(0xFF00ACC1) : Colors.grey.shade300, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF00ACC1) : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? const Color(0xFF00ACC1) : Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}