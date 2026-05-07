import 'package:flutter/material.dart';

// Si estos nombres subrayan en rojo, es que el archivo se llama distinto en tu carpeta
import 'dashboard_screen.dart';
import 'schedule_screen.dart';
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
    // Definimos la lista aquí adentro para evitar errores de inicialización
    final List<Widget> screens = [
      DashboardScreen(), 
      ScheduleScreen(),  
      InventoryScreen(), 
      ProfileScreen(),   
    ];

    return Scaffold(
      // IndexedStack mantiene el estado de las pantallas al cambiar de pestaña
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
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00ACC1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Historial"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Inventario"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}