import 'package:flutter/material.dart';

class NotaDeVozScreen extends StatefulWidget {
  final String userName;

  const NotaDeVozScreen({super.key, required this.userName});

  @override
  State<NotaDeVozScreen> createState() => _NotaDeVozScreenState();
}

class _NotaDeVozScreenState extends State<NotaDeVozScreen> {
  // Controladores de estado
  bool _isRecording = false;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. ENCABEZADO DE LA TARJETA
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryCyan,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.mic, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "Nota de Voz",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006064),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),

                // 2. PANEL DE GRABACIÓN INTERACTIVO
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF), // Celeste suave de tu UI
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE0F2FE)),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isRecording = !_isRecording;
                            if (_isRecording) {
                              _urlController.text = "Grabando audio en vivo...";
                            } else {
                              _urlController.text = "content://media/audio/dosify_record_01.mp3";
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: _isRecording ? Colors.redAccent : primaryCyan,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_isRecording ? Colors.redAccent : primaryCyan).withOpacity(0.3),
                                blurRadius: _isRecording ? 20 : 10,
                                spreadRadius: _isRecording ? 4 : 1,
                              )
                            ],
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _isRecording ? "Grabando... Presiona para detener" : "Presiona para grabar",
                        style: TextStyle(
                          color: _isRecording ? Colors.redAccent : const Color(0xFF006064),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 3. CAMPO: URL DE AUDIO
                const Text(
                  "URL de Audio",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064), fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _urlController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "URL del audio grabado",
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 25),

                // 4. CAMPO: FECHA
                const Text(
                  "Fecha",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064), fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _fechaController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "dd/mm/aaaa",
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    suffixIcon: const Icon(Icons.calendar_today_outlined, color: Color(0xFFBAE6FD), size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF0F9FF),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFFBAE6FD)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFFBAE6FD)),
                    ),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _fechaController.text = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                      });
                    }
                  },
                ),
                const SizedBox(height: 35),

                // 5. BOTÓN DE GUARDAR NOTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_urlController.text.isEmpty || _urlController.text.contains("Grabando")) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Por favor, graba un audio antes de guardar")),
                        );
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Nota de voz guardada correctamente")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryCyan,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      "Guardar Nota",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}