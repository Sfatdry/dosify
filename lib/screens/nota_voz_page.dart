import 'package:flutter/material.dart';
import 'app_theme.dart';

class NotaVozPage extends StatefulWidget {
  @override
  _NotaVozPageState createState() => _NotaVozPageState();
}

class _NotaVozPageState extends State<NotaVozPage> {
  bool isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [DosifyTheme.lightSky, Color(0xFFE0F7FA)]),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: DosifyTheme.borderSky),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => isRecording = !isRecording),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isRecording ? Colors.red.withOpacity(0.1) : DosifyTheme.primaryCyan,
                      shape: BoxShape.circle,
                      boxShadow: [if(isRecording) BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
                    ),
                    child: Icon(
                      isRecording ? Icons.stop : Icons.mic,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isRecording ? "Grabando..." : "Toca para grabar",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF164E63)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(decoration: DosifyTheme.inputDecoration("URL de Audio", Icons.link)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0891B2),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("Guardar Nota", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}