import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'tratamiento_screen.dart';
import 'inventory_screen.dart';
import 'recordatorio_screen.dart';
import 'medicamento_screen.dart';
import 'dosis_screen.dart';
import 'dieta_screen.dart';
import 'nota_de_voz_screen.dart';
import 'farmacia_screen.dart'; 
import 'historial_screen.dart';

class MainNavigation extends StatefulWidget {
  final String userName;
  const MainNavigation({super.key, required this.userName});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  late List<Widget> _screens;
  final ScrollController _scrollController = ScrollController(); // Controlador para la barrita deslizable

  @override
  void initState() {
    super.initState();
    
    _screens = [
      DashboardScreen(userName: widget.userName),
      ProfileScreen(userName: widget.userName),
      TratamientoScreen(userName: widget.userName),
      HistorialScreen(userName: widget.userName),   
      MedicamentoScreen(userName: widget.userName), 
      DosisScreen(userName: widget.userName),      
      RecordatorioScreen(userName: widget.userName),
      InventoryScreen(userName: widget.userName),
      DietaScreen(userName: widget.userName),      
      NotaDeVozScreen(userName: widget.userName),  
      FarmaciaScreen(userName: widget.userName),    
    ];
  }

  final List<Map<String, dynamic>> _menuItems = [
    {'label': 'Dashboard', 'icon': Icons.grid_view_rounded},
    {'label': 'Usuario', 'icon': Icons.person_outline_rounded},
    {'label': 'Tratamiento', 'icon': Icons.assignment_outlined},
    {'label': 'Historial', 'icon': Icons.bar_chart_rounded}, 
    {'label': 'Medicamento', 'icon': Icons.link_rounded},
    {'label': 'Dosis', 'icon': Icons.check_circle_outline_rounded},
    {'label': 'Recordatorio', 'icon': Icons.notifications_none_rounded},
    {'label': 'Inventario', 'icon': Icons.archive_outlined},
    {'label': 'Dieta', 'icon': Icons.restaurant_rounded},
    {'label': 'Nota de Voz', 'icon': Icons.mic_none_rounded},
    {'label': 'Farmacia', 'icon': Icons.local_pharmacy_rounded}, 
  ];

  // Funciones para mover la barra con las flechas de guía
  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 150,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 150,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    String initial = widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : "A";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // --- HEADER PRINCIPAL ÚNICO ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00ACC1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Dosify", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
                        Text("Control inteligente de medicamentos", style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Bienvenida", style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(widget.userName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
                      ],
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF00C853),
                      child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- BARRA DE MENÚ CON TAMAÑO NORMAL, SCROLL Y BOTONES DE GUÍA ---
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // Flecha Izquierda
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF64748B)),
                  onPressed: _scrollLeft,
                ),
                
                // El contenedor del Scroll en su tamaño original
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: List.generate(_menuItems.length, (index) {
                          bool isSelected = _selectedIndex == index;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedIndex = index),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), // Regresa el padding premium
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF00ACC1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _menuItems[index]['icon'],
                                    size: 18, // Tamaño normal de icono
                                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _menuItems[index]['label'],
                                    style: TextStyle(
                                      fontSize: 13, // Tamaño de fuente original
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),

                // Flecha Derecha para que sepa que hay más contenido
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
                  onPressed: _scrollRight,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // --- CONTENIDO VARIABLE ---
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}