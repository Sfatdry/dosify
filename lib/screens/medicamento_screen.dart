import 'package:flutter/material.dart';

class MedicamentoScreen extends StatefulWidget {
  final String userName;

  const MedicamentoScreen({super.key, required this.userName});

  @override
  State<MedicamentoScreen> createState() => _MedicamentoScreenState();
}

class _MedicamentoScreenState extends State<MedicamentoScreen> {
  // Variables para controlar el formulario inferior
  bool _isCritico = true;
  final TextEditingController _nombreController = TextEditingController(text: "Amoxicilina");
  final TextEditingController _dosisController = TextEditingController(text: "500mg");
  final TextEditingController _frecuenciaController = TextEditingController(text: "8");
  final TextEditingController _duracionController = TextEditingController(text: "7");

  @override
  void dispose() {
    _nombreController.dispose();
    _dosisController.dispose();
    _frecuenciaController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GRID / FILA DE TARJETAS DE MEDICAMENTOS (Scroll Horizontal)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMedOverviewCard("Amoxicilina", "500mg", "Cada 8h", "21 unidades", Colors.cyan, false, isSelected: true),
                  const SizedBox(width: 20),
                  _buildMedOverviewCard("Losartán", "50 mg", "Cada 24h", "28 unidades", Colors.pink, true, isSelected: false),
                  const SizedBox(width: 20),
                  _buildMedOverviewCard("Metformina", "850mg", "Cada 12h", "60 unidades", Colors.purple, true, isSelected: false),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 2. CONTENEDOR PRINCIPAL: DETALLES DEL MEDICAMENTO (FORMULARIO)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado de la configuración
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.display_settings, color: primaryCyan),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Detalles del Medicamento", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
                          Text("Configuración y dosificación", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 35),

                  // Campo: Nombre del medicamento
                  _buildLabel("Nombre del medicamento"),
                  _buildTextField(_nombreController, Icons.link, primaryCyan),
                  const SizedBox(height: 25),

                  // Campo: Dosis
                  _buildLabel("Dosis"),
                  _buildTextField(_dosisController, null, primaryCyan),
                  const SizedBox(height: 25),

                  // Fila dividida: Frecuencia y Duración
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Frecuencia (horas)"),
                            _buildTextField(_frecuenciaController, Icons.access_time, primaryCyan),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Duración (días)"),
                            _buildTextField(_duracionController, Icons.calendar_today_outlined, primaryCyan),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Banner interactivo: Medicamento Crítico
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isCritico = !_isCritico;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xFFE0F2FE)),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isCritico,
                            activeColor: Colors.orange,
                            onChanged: (val) {
                              setState(() {
                                _isCritico = val ?? false;
                              });
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Medicamento crítico", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064), fontSize: 15)),
                              Text("Requiere adherencia estricta", style: TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),

                  // Botones de Acción Inferiores (Guardar y Cancelar)
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Medicamento guardado con éxito")),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryCyan,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Guardar Medicamento", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Cancelar", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064), fontSize: 14)),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData? prefixIcon, Color activeColor) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: activeColor, size: 20) : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: activeColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildMedOverviewCard(String name, String mg, String freq, String units, Color iconColor, bool isCritico, {required bool isSelected}) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isSelected ? const Color(0xFF00ACC1) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.1),
                // ICONO CORREGIDO AQUÍ:
                child: Icon(Icons.medication, color: iconColor, size: 20),
              ),
              if (isCritico)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFFE4E6), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: const [
                      Icon(Icons.bolt, color: Colors.pink, size: 12),
                      SizedBox(width: 4),
                      Text("Crítico", style: TextStyle(color: Colors.pink, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
            ],
          ),
          const SizedBox(height: 20),
          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006064))),
          const SizedBox(height: 15),
          _rowItem(Icons.blur_on, mg),
          _rowItem(Icons.access_time, freq),
          _rowItem(Icons.inventory_2_outlined, units),
        ],
      ),
    );
  }

  Widget _rowItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 18),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
        ],
      ),
    );
  }
}