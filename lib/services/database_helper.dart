import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseHelper {
  final _supabase = Supabase.instance.client;

  Future<void> guardarMedicamento({
    required String nombre,
    required String dosis,
    required int frecuencia,
    required int duracion,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Sesión expirada");

    // Buscamos tratamiento
    final List<dynamic> datos = await _supabase
        .from('tratamiento')
        .select()
        .eq('usuario_id', user.id);

    dynamic tId;
    if (datos.isEmpty) {
      final nuevo = await _supabase.from('tratamiento').insert({
        'usuario_id': user.id,
        'nombre': 'Tratamiento Principal',
        'estado': 'activo'
      }).select().single();
      tId = nuevo['id'];
    } else {
      tId = datos[0]['id'];
    }

    // Insertar medicamento
    await _supabase.from('medicamento').insert({
      'tratamiento_id': tId,
      'nombre': nombre,
      'dosis': dosis,
      'frecuencia_horas': frecuencia,
      'duracion_dias': duracion,
      'es_critico': false,
    });
  }
}
class RegistroMedicamentoScreen extends StatefulWidget {
  const RegistroMedicamentoScreen({super.key});

  @override
  State<RegistroMedicamentoScreen> createState() => _RegistroMedicamentoScreenState();
}

class _RegistroMedicamentoScreenState extends State<RegistroMedicamentoScreen> {
  final _nombreController = TextEditingController();
  final _dosisController = TextEditingController();
  final _duracionController = TextEditingController();
  
  String _frecuencia = 'Cada 8 horas (3x al día)';
  bool _isSaving = false; 

  int _obtenerHoras(String texto) {
    if (texto.contains('6')) return 6;
    if (texto.contains('8')) return 8;
    if (texto.contains('12')) return 12;
    return 24;
  }

  // --- ESTA ES LA FUNCIÓN QUE TE FALTABA ---
  Future<void> _guardarDatos() async {
    if (_nombreController.text.trim().isEmpty || _duracionController.text.trim().isEmpty) {
      _mostrarMensaje("Por favor llena los campos", Colors.orange);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await DatabaseHelper().guardarMedicamento(
        nombre: _nombreController.text.trim(),
        dosis: _dosisController.text.trim(),
        frecuencia: _obtenerHoras(_frecuencia),
        duracion: int.parse(_duracionController.text.trim()),
      );

      if (mounted) {
        _mostrarMensaje("¡Guardado en Supabase! 💊", Colors.green);
        _nombreController.clear();
        _dosisController.clear();
        _duracionController.clear();
      }
    } catch (e) {
      if (mounted) _mostrarMensaje("Error: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo Registro", style: TextStyle(color: DosifyTheme.azulPrincipal, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DosifyTheme.azulPrincipal),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Registro de\nMedicamento", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: DosifyTheme.azulPrincipal)),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _buildInput("Nombre del Medicamento", "ej. Paracetamol", _nombreController),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildInput("Dosis", "500mg", _dosisController)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildInput("Días", "7", _duracionController, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _guardarDatos,
                style: ElevatedButton.styleFrom(backgroundColor: DosifyTheme.azulPrincipal),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Guardar Tratamiento", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, String hint, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Frecuencia", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: _frecuencia,
          isExpanded: true,
          items: ['Cada 6 horas (4x al día)', 'Cada 8 horas (3x al día)', 'Cada 12 horas (2x al día)', 'Una vez al día']
              .map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
          onChanged: (val) => setState(() => _frecuencia = val!),
        ),
      ],
    );
  }
}