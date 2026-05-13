import 'package:flutter/material.dart';

// Importamos TODAS las pantallas
import 'dashboard_screen.dart';
import 'recordatorio_screen.dart';    // Tus horarios/calendario
import 'historial_screen.dart';   // El diseño Pro del 94%
import 'inventory_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Agregamos HistorialScreen a la lista
    final List<Widget> screens = [
      const DashboardScreen(userName: "María"), 
      const RecordatorioScreen(),    // Pestaña 1: Horarios
      const HistorialScreen(),   // Pestaña 2: ¡EL DISEÑO PRO!
      const InventoryScreen(), 
      const ProfileScreen(),    
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // Importante para que quepan 5 iconos
        selectedItemColor: const Color(0xFF00ACC1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: "Horario"), // Schedule
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Historial"), // El 94%
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Inventario"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}