import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class TratamientoScreen extends StatefulWidget {
  final String? userName; 

  const TratamientoScreen({super.key, this.userName});

  @override
  State<TratamientoScreen> createState() => _TratamientoScreenState();
}

class _TratamientoScreenState extends State<TratamientoScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final Uuid _uuidGenerator = const Uuid();

  final TextEditingController _nombreController = TextEditingController();

  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  bool _isLoadingUser = true;
  bool _isSaving = false;
  String? _currentUserId; 

  @override
  void initState() {
    super.initState();
    _obtenerUsuarioActivo(); 
  }

  Future<void> _obtenerUsuarioActivo() async {
    try {
      final List<dynamic> response = await supabase
          .from('usuario')
          .select('id')
          .order('fecha_registro', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        _currentUserId = response.first['id'];
      } else {
        _currentUserId = supabase.auth.currentUser?.id;
      }
    } catch (e) {
      debugPrint("Error obteniendo usuario: $e");
      _currentUserId = supabase.auth.currentUser?.id;
    } finally {
      if (mounted) {
        setState(() => _isLoadingUser = false);
      }
    }
  }

  Future<void> _seleccionarFecha(BuildContext context, bool esFechaInicio) async {
    final DateTime hoy = DateTime.now();
    
    final DateTime? seleccionado = await showDatePicker(
      context: context,
      initialDate: esFechaInicio 
          ? (_fechaInicio ?? hoy) 
          : (_fechaFin ?? _fechaInicio ?? hoy),
      firstDate: esFechaInicio ? hoy : (_fechaInicio ?? hoy), 
      lastDate: DateTime(hoy.year + 5), 
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00ACC1), 
              onPrimary: Colors.white,
              onSurface: Color(0xFF006064),
            ),
          ),
          child: child!,
        );
      },
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
    if (_nombreController.text.trim().isEmpty || _fechaInicio == null || _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, pon el nombre del tratamiento y ambas fechas"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_currentUserId == null) {
      _currentUserId = _uuidGenerator.v4(); 
    }

    setState(() => _isSaving = true);

    try {
      final String tratamientoId = _uuidGenerator.v4();

      final mapTratamiento = {
        'id': tratamientoId,
        'usuario_id': _currentUserId, 
        'nombre': _nombreController.text.trim(), 
        'fecha_inicio': DateFormat('yyyy-MM-dd').format(_fechaInicio!),
        'fecha_fin': DateFormat('yyyy-MM-dd').format(_fechaFin!),
        'estado': 'Activo',
      };

      await supabase.from('tratamiento').insert(mapTratamiento);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Tratamiento registrado con éxito!"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al registrar en Supabase: $error"),
            backgroundColor: Colors.red,
          ),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator(color: primaryCyan))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nuevo Tratamiento",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textCyan),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Define los rangos de tu medicación",
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 40),

                  const Text("Nombre del tratamiento", style: TextStyle(fontWeight: FontWeight.bold, color: textCyan, fontSize: 15)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      hintText: "Ej. Paracetamol 500mg, Omeprazol...",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: const Icon(Icons.medical_services_outlined, color: primaryCyan, size: 22),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: primaryCyan, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  const Text("Fecha de inicio", style: TextStyle(fontWeight: FontWeight.bold, color: textCyan, fontSize: 15)),
                  const SizedBox(height: 10),
                  _buildDatePickerButton(
                    texto: _fechaInicio == null 
                        ? "Seleccionar fecha de inicio" 
                        : DateFormat('dd / MM / yyyy').format(_fechaInicio!),
                    icon: Icons.calendar_today_rounded,
                    color: primaryCyan,
                    onTap: () => _seleccionarFecha(context, true),
                  ),
                  const SizedBox(height: 25),

                  const Text("Fecha de finalización", style: TextStyle(fontWeight: FontWeight.bold, color: textCyan, fontSize: 15)),
                  const SizedBox(height: 10),
                  _buildDatePickerButton(
                    texto: _fechaFin == null 
                        ? "Seleccionar fecha de fin" 
                        : DateFormat('dd / MM / yyyy').format(_fechaFin!),
                    icon: Icons.calendar_month_rounded,
                    color: primaryCyan,
                    onTap: _fechaInicio == null 
                        ? null 
                        : () => _seleccionarFecha(context, false),
                  ),
                  const SizedBox(height: 45),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _guardarTratamiento,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Registrar Tratamiento",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                ],
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
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        // 🚨 CORREGIDO: Se quitó el 'const' decorador que impedía compilar tonalidades de gris personalizados
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200), 
        ),
        child: Row(
          children: [
            Icon(icon, color: onTap == null ? Colors.grey.shade400 : color, size: 22),
            const SizedBox(width: 15),
            Text(
              texto,
              style: TextStyle(
                color: onTap == null 
                    ? Colors.grey.shade400 
                    : (_fechaInicio != null || _fechaFin != null ? Colors.black87 : Colors.grey.shade500),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}