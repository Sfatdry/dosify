import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'tratamiento_screen.dart';
import 'inventory_screen.dart';
import 'recordatorio_screen.dart';

class MainNavigation extends StatefulWidget {
  final String userName;
  const MainNavigation({super.key, required this.userName});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Lista de pantallas (puedes crear placeholders para Medicamento, Dosis, etc.)
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(userName: widget.userName),
      ProfileScreen(userName: widget.userName),
      TratamientoScreen(userName: widget.userName),
      const Center(child: Text("Pantalla Medicamento")), // Placeholder
      const Center(child: Text("Pantalla Dosis")),       // Placeholder
      RecordatorioScreen(userName: widget.userName),
      InventoryScreen(userName: widget.userName),
    ];
  }

  // Definición de los items del menú según tu captura
  final List<Map<String, dynamic>> _menuItems = [
    {'label': 'Dashboard', 'icon': Icons.dashboard},
    {'label': 'Usuario', 'icon': Icons.person_outline},
    {'label': 'Tratamiento', 'icon': Icons.assignment_outlined},
    {'label': 'Medicamento', 'icon': Icons.link},
    {'label': 'Dosis', 'icon': Icons.check_circle_outline},
    {'label': 'Recordatorio', 'icon': Icons.notifications_none},
    {'label': 'Inventario', 'icon': Icons.inventory_2_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    String initial = widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : "M";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // --- HEADER SUPERIOR (Dosify + Bienvenida) ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.medication, color: Color(0xFF00ACC1), size: 30),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Dosify", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
                        Text("Control inteligente de medicamentos", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Bienvenida", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text(widget.userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
                      ],
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: const Color(0xFF00C853),
                      child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- BARRA DE MENÚ CON SCROLL HORIZONTAL ---
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00ACC1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _menuItems[index]['icon'],
                          size: 18,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _menuItems[index]['label'],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // --- CONTENIDO DE LA PANTALLA ---
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
}