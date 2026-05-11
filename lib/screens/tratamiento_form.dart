import 'package:flutter/material.dart';
import 'shared_theme.dart';

class TratamientoForm extends StatefulWidget {
  @override
  _TratamientoFormState createState() => _TratamientoFormState();
}

class _TratamientoFormState extends State<TratamientoForm> {
  String _estado = 'activo';
  DateTime? _fechaInicio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estado del Tratamiento', style: TextStyle(color: AppColors.cyan900, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _estado,
            decoration: customInputDecoration(hintText: 'Estado', icon: Icons.info_outline),
            items: ['activo', 'completado', 'pausado'].map((String val) {
              return DropdownMenuItem(value: val, child: Text(val.toUpperCase()));
            }).toList(),
            onChanged: (val) => setState(() => _estado = val!),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            icon: Icon(Icons.calendar_today),
            label: Text(_fechaInicio == null ? 'Seleccionar Fecha Inicio' : _fechaInicio.toString().split(' ')[0]),
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _fechaInicio = picked);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.cyan900,
              backgroundColor: AppColors.sky50,
              minimumSize: Size(double.infinity, 50),
              side: BorderSide(color: AppColors.sky200),
            ),
          ),
        ],
      ),
    );
  }
}