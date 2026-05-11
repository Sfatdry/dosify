import 'package:flutter/material.dart';
import 'shared_theme.dart';

class NotaVozForm extends StatefulWidget {
  @override
  _NotaVozFormState createState() => _NotaVozFormState();
}

class _NotaVozFormState extends State<NotaVozForm> {
  bool _grabando = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => setState(() => _grabando = !_grabando),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _grabando ? Colors.red[100] : AppColors.sky50,
                  shape: BoxShape.circle,
                  border: Border.all(color: _grabando ? Colors.red : AppColors.cyan500, width: 2),
                ),
                child: Icon(
                  _grabando ? Icons.stop : Icons.mic,
                  size: 40,
                  color: _grabando ? Colors.red : AppColors.cyan600,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _grabando ? 'Grabando...' : 'Pulsa para grabar nota',
              style: TextStyle(color: AppColors.cyan900, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}