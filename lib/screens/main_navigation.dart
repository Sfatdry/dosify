import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'recordatorio_screen.dart'; 
import 'historial_screen.dart';
import 'inventory_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  // 1. Agregamos el parámetro para recibir el nombre del login
  final String userName; 
  
  const MainNavigation({super.key, required this.userName});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 2. Creamos la lista de pantallas usando el nombre real (widget.userName)
// Busca la lista _screens dentro de _MainNavigationState
final List<Widget> _screens = [
  DashboardScreen(userName: widget.userName),
  
  // ERROR 1 CORREGIDO: Quitamos 'const' y pasamos userName
  RecordatorioScreen(userName: widget.userName), 
  
  // ERROR 2 CORREGIDO: Quitamos 'const' y pasamos userName
  HistorialScreen(userName: widget.userName),    
  
  InventoryScreen(userName: widget.userName),
  ProfileScreen(userName: widget.userName),
];
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens, // <--- Asegúrate que este nombre coincida con la lista de arriba
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: "Horario"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Historial"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: "Inventario"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Perfil"),
        ],
      ),
    );
  }
}