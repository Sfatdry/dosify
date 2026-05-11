import 'package:flutter/material.dart';
import 'shared_theme.dart';

class UsuarioForm extends StatefulWidget {
  @override
  _UsuarioFormState createState() => _UsuarioFormState();
}

class _UsuarioFormState extends State<UsuarioForm> {
  final _nombreController = TextEditingController(text: 'María Fernanda González');
  final _emailController = TextEditingController(text: 'maria.gonzalez@email.com');
  final _passController = TextEditingController(text: '********');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Tarjeta de Estadística (Dashboard-like)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tratamientos activos', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    Text('3', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.cyan600)),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.cyan500, AppColors.cyan600]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.show_chart, color: Colors.white, size: 28),
                )
              ],
            ),
          ),
          SizedBox(height: 24),
          // Formulario
          TextField(
            controller: _nombreController,
            decoration: customInputDecoration(hintText: 'Nombre', icon: Icons.person),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: customInputDecoration(hintText: 'Email', icon: Icons.email),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _passController,
            obscureText: true,
            decoration: customInputDecoration(hintText: 'Contraseña', icon: Icons.lock),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => print('Guardado: ${_nombreController.text}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cyan600,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Guardar Cambios', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}