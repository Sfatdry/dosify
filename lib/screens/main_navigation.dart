import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'historial_screen.dart';
import 'inventory_screen.dart';
import 'profile_screen.dart';
import 'recordatorio_screen.dart'; 
import 'tratamiento_screen.dart'; // ¡Listo!

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
    // 1. LISTADO COMPLETO CON LAS 6 PANTALLAS
    final List<Widget> _screens = [
      DashboardScreen(userName: widget.userName),     // Índice 0
      RecordatorioScreen(userName: widget.userName),  // Índice 1
      HistorialScreen(userName: widget.userName),     // Índice 2
      InventoryScreen(userName: widget.userName),     // Índice 3
      ProfileScreen(userName: widget.userName),       // Índice 4
      TratamientoScreen(userName: widget.userName),   // Índice 5 (Nueva pantalla)
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      // 2. BOTÓN FLOTANTE PARA LA INTERFAZ DE TRATAMIENTO
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _selectedIndex = 5; // Cambia directamente a la pantalla de Tratamiento
          });
        },
        backgroundColor: const Color(0xFF00ACC1),
        shape: const CircleBorder(),
        child: const Icon(Icons.calendar_today, color: Colors.white),
      ),
      // Coloca el botón flotante en medio de la barra inferior
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // 3. BARRA DE NAVEGACIÓN ADAPTADA PARA DEJAR ESPACIO EN MEDIO
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex == 5 ? 0 : _selectedIndex, // Evita errores visuales si está en tratamiento
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF00ACC1),
          unselectedItemColor: Colors.grey,
          elevation: 0,
          backgroundColor: Colors.transparent, // Permite ver el diseño del BottomAppBar
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Alertas'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Inventario'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}