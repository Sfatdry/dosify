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

  Future<void> _cargarTratamientosDesdeSupabase() async {
    try {
      setState(() => _isLoadingData = true);
      
      final String? userId = supabase.auth.currentUser?.id;

      PostgrestFilterBuilder query = supabase.from('tratamiento').select();
      
      if (userId != null) {
        query = query.eq('usuario_id', userId);
      }

      final List<dynamic> response = await query.order('fecha_inicio', ascending: false);

      setState(() {
        _listaTratamientos = response;
      });
    } catch (e) {
      debugPrint("Error cargando tratamientos en el Dashboard: $e");
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

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
      backgroundColor: Colors.white,
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
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator(color: primaryCyan))
          : _listaTratamientos.isEmpty
              ? _buildDashboardVacio()
              : _buildListaDeTratamientos(),
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryCyan,
        onPressed: _irARegistrarTratamiento, 
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildDashboardVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_liquid_sharp, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            "No tienes tratamientos activos",
            style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            "Toca el botón '+' para agregar uno nuevo.",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildListaDeTratamientos() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      itemCount: _listaTratamientos.length,
      itemBuilder: (context, index) {
        final tratamiento = _listaTratamientos[index];
        
        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 10),
          color: const Color(0xFFF8FAFC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.grey.shade200), 
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF00ACC1),
              child: Icon(Icons.medical_services_outlined, color: Colors.white),
            ),
            title: Text(
              tratamiento['nombre'] ?? 'Sin Nombre',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064), fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                "Inicio: ${tratamiento['fecha_inicio']}  |  Fin: ${tratamiento['fecha_fin']}",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Activo",
                style: TextStyle(color: Color(0xFF00838F), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}