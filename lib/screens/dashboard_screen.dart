import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tratamiento_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String? userName;
  const DashboardScreen({super.key, this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  List<dynamic> _listaTratamientos = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _cargarTratamientosDesdeSupabase(); 
  }

  // Cargar tratamientos desde la base de datos de Supabase
  Future<void> _cargarTratamientosDesdeSupabase() async {
    try {
      setState(() => _isLoadingData = true);
      
      final String? userId = supabase.auth.currentUser?.id;
      PostgrestFilterBuilder query = supabase.from('tratamiento').select();
      
      if (userId != null) {
        query = query.eq('usuario_id', userId);
      }

      // Ordenamos cronológicamente por fecha de inicio como en tu diseño
      final List<dynamic> response = await query.order('fecha_inicio', ascending: true);

      setState(() {
        _listaTratamientos = response;
      });
    } catch (e) {
      debugPrint("Error cargando tratamientos: $e");
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  // Eliminar un tratamiento de Supabase por su ID
  Future<void> _eliminarTratamiento(String id) async {
    try {
      await supabase.from('tratamiento').delete().eq('id', id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tratamiento eliminado con éxito"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      _cargarTratamientosDesdeSupabase();
    } catch (e) {
      debugPrint("Error al eliminar tratamiento: $e");
    }
  }

  // Navegar a la pantalla de registro y refrescar si devuelve un éxito (true)
  void _irARegistrarTratamiento() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TratamientoScreen(userName: widget.userName),
      ),
    );

    if (resultado == true) {
      _cargarTratamientosDesdeSupabase(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);
    const Color textCyan = Color(0xFF006064);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Fondo original ligeramente gris
      appBar: AppBar(
        title: Text(
          "Dosify - Bienvenido ${widget.userName ?? 'Usuario'}", 
          style: const TextStyle(color: textCyan, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: primaryCyan),
            onPressed: _cargarTratamientosDesdeSupabase, 
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 💡 NOTA: Aquí conservas intactos tus bloques de "Tratamientos activos",
            // "Dosis tomadas hoy", "Dosis pendientes", "Próximas dosis" e "Historial de hoy".

            const SizedBox(height: 20),
            
            // --- SECCIÓN INFERIOR DE TRATAMIENTOS ACTIVOS EN CURSO ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 2,
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFAB47BC).withOpacity(0.2), // Morado suave corregido
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.assignment_outlined, color: Color(0xFF9C27B0)),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tratamientos activos",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          Text(
                            "En curso",
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Cuadrícula Horizontal de Tarjetas Lavanda
                  _isLoadingData
                      ? const Center(child: CircularProgressIndicator(color: primaryCyan))
                      : _listaTratamientos.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                "No hay tratamientos registrados.", 
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                            )
                          : SizedBox(
                              height: 160, // Altura ideal para la fila horizontal
                              child: GridView.builder(
                                scrollDirection: Axis.horizontal,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  mainAxisExtent: 250, // Ancho exacto de cada tarjeta
                                  mainAxisSpacing: 15,
                                ),
                                itemCount: _listaTratamientos.length,
                                itemBuilder: (context, index) {
                                  final tratamiento = _listaTratamientos[index];
                                  return _buildTarjetaTratamientoOriginal(tratamiento);
                                },
                              ),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryCyan,
        onPressed: _irARegistrarTratamiento, 
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  // Constructor de tus tarjetas moradas originales con estado dinámico y botón eliminar
  Widget _buildTarjetaTratamientoOriginal(dynamic tratamiento) {
    // Obtenemos el estado directo de Supabase o asignamos 'activo' por defecto
    final String estado = (tratamiento['estado'] ?? 'activo').toString().toLowerCase();

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF).withOpacity(0.5), // Tu fondo morado claro original
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE9D5FF), width: 1),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Etiqueta de Estado Dinámica (Verde para activo, gris para el resto)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: estado == 'activo' ? const Color(0xFFA7F3D0) : Colors.grey.shade200, 
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    color: estado == 'activo' ? const Color(0xFF065F46) : Colors.grey.shade700, 
                    fontSize: 11, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              
              // Nombre del medicamento/tratamiento
              Text(
                tratamiento['nombre'] ?? 'Sin Nombre',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              
              // Fechas dinámicas desde Supabase
              Text(
                "Inicio: ${tratamiento['fecha_inicio']}",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                "Fin: ${tratamiento['fecha_fin']}",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          
          // Botón sutil de eliminación (Círculo rojo suave con cruz) en la esquina derecha
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: () => _eliminarTratamiento(tratamiento['id'].toString()),
              child: Icon(Icons.disabled_by_default_rounded, color: Colors.red.shade300, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}