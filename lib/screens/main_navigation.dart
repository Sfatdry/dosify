import 'package:flutter/material.dart';
// Asegúrate de que estas rutas coincidan con tus archivos reales
import 'dashboard_screen.dart';
import 'historial_screen.dart';
import 'inventory_screen.dart';
import 'profile_screen.dart';
import 'recordatorio_screen.dart'; // Verifica que el archivo se llame así

class MainNavigation extends StatefulWidget {
  final String userName;

  const MainNavigation({super.key, required this.userName});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 2. Lista de pantallas corregida
    final List<Widget> _screens = [
      DashboardScreen(userName: widget.userName),
      // Si tu clase se llama RecordatorioScreen, asegúrate de que acepte userName
      RecordatorioScreen(userName: widget.userName), 
      HistorialScreen(userName: widget.userName),
      InventoryScreen(userName: widget.userName),
      ProfileScreen(userName: widget.userName),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Recordatorios'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Inventario'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}