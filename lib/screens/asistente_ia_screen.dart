import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AsistenteIaScreen extends StatefulWidget {
  final String userName;
  final String userId;
  const AsistenteIaScreen({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  State<AsistenteIaScreen> createState() => _AsistenteIaScreenState();
}

class _AsistenteIaScreenState extends State<AsistenteIaScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  String _geminiApiKey =
      ''; // Clave de API de Gemini opcional (se carga de SharedPreferences)

  // Datos contextuales del usuario
  List<Map<String, dynamic>> _medicamentos = [];
  List<Map<String, dynamic>> _dosis = [];
  List<Map<String, dynamic>> _dietas = [];
  List<Map<String, dynamic>> _tratamientos = [];

  @override
  void initState() {
    super.initState();
    _loadUserContext();
    _loadApiKey();
    _addInitialMessage();
  }

  Future<void> _loadApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = prefs.getString('gemini_api_key');
      if (key != null && mounted) {
        setState(() {
          _geminiApiKey = key;
        });
      }
    } catch (e) {
      debugPrint('Error cargando API key: $e');
    }
  }

  void _addInitialMessage() {
    _messages.add({
      'text':
          '¡Hola, ${widget.userName}! Soy tu asistente personal de Dosify. 🤖💊\n\n¿En qué puedo ayudarte hoy? Puedes preguntarme sobre tus medicamentos, dosis del día, tu dieta o consejos de salud.',
      'isUser': false,
      'time': DateFormat('h:mm a').format(DateTime.now()),
    });
  }

  Future<void> _loadUserContext() async {
    try {
      final String userId = widget.userId;

      // 1. Tratamientos
      final trats = await _supabase
          .from('tratamiento')
          .select()
          .eq('usuario_id', userId);
      _tratamientos = List<Map<String, dynamic>>.from(trats);
      final listTratIds = _tratamientos.map((t) => t['id'].toString()).toList();

      if (listTratIds.isEmpty) return;

      // 2. Medicamentos
      final meds = await _supabase
          .from('medicamento')
          .select()
          .inFilter('tratamiento_id', listTratIds);
      _medicamentos = List<Map<String, dynamic>>.from(meds);
      final listMedIds = _medicamentos.map((m) => m['id'].toString()).toList();

      // 3. Dietas
      final diets = await _supabase
          .from('dieta')
          .select()
          .inFilter('tratamiento_id', listTratIds);
      _dietas = List<Map<String, dynamic>>.from(diets);

      if (listMedIds.isEmpty) return;

      // 4. Dosis
      final ds = await _supabase
          .from('dosis')
          .select()
          .inFilter('medicamento_id', listMedIds);
      _dosis = List<Map<String, dynamic>>.from(ds);
    } catch (e) {
      debugPrint('Error cargando contexto de IA: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'time': DateFormat('h:mm a').format(DateTime.now()),
      });
      _isTyping = true;
    });

    _scrollToBottom();

    // Obtener respuesta de la IA (Gemini si hay clave, si no Local Engine)
    String responseText = '';
    try {
      if (_geminiApiKey.isNotEmpty) {
        try {
          responseText = await _getGeminiResponse(text);
        } catch (geminiError) {
          debugPrint('Gemini error: $geminiError');
          final localRes = await _getLocalResponse(text);
          responseText =
              '⚠️ *Nota:* Hubo un problema al conectar con Gemini (posiblemente la clave de API sea inválida o esté vencida). Utilizando el motor local offline:\n\n$localRes';
        }
      } else {
        responseText = await _getLocalResponse(text);
      }
    } catch (e) {
      responseText = 'Lo siento, ocurrió un error al procesar tu consulta: $e';
    }

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'text': responseText,
          'isUser': false,
          'time': DateFormat('h:mm a').format(DateTime.now()),
        });
      });
      _scrollToBottom();
    }
  }

  // LLamada directa a la API de Gemini (Fast and zero-config wrapper)
  Future<String> _getGeminiResponse(String prompt) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_geminiApiKey',
    );

    // Adjuntamos datos del contexto para que Gemini los use en la respuesta
    final contextPrompt =
        '''
    Eres un asistente médico inteligente y amigable llamado "Dosify AI". Tu objetivo es ayudar a ${widget.userName} con su salud.
    
    Información real del paciente en la app:
    - Tratamientos: ${_tratamientos.map((t) => "${t['nombre']} (${t['estado']})").join(', ')}
    - Medicamentos: ${_medicamentos.map((m) => "${m['nombre']} (Dosis: ${m['dosis']}, cada ${m['frecuencia_horas']} horas)").join(', ')}
    - Dietas programadas: ${_dietas.map((d) => d['descripcion']).join(', ')}
    - Dosis registradas hoy: ${_getDosisHoyResumen()}
    
    Instrucciones de comportamiento:
    - Sé conciso, profesional y empático.
    - Responde en español de forma clara.
    - Si te preguntan algo médico complejo, añade siempre la recomendación de consultar con su médico.
    
    Pregunta del usuario: $prompt
    ''';

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': contextPrompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String text =
          data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
      return text.trim();
    } else {
      throw Exception('Código de error Gemini: ${response.statusCode}');
    }
  }

  // Resumen de las dosis de hoy
  String _getDosisHoyResumen() {
    final hoy = DateTime.now();
    final dosisHoy = _dosis.where((d) {
      if (d['fecha_hora'] == null) return false;
      final f = DateTime.parse(d['fecha_hora']).toLocal();
      return f.year == hoy.year && f.month == hoy.month && f.day == hoy.day;
    }).toList();

    if (dosisHoy.isEmpty) return "Ninguna dosis programada para hoy.";
    return dosisHoy
        .map((d) {
          final med = _medicamentos.firstWhere(
            (m) => m['id'].toString() == d['medicamento_id'].toString(),
            orElse: () => {'nombre': 'Medicamento desconocido'},
          );
          return "${med['nombre']} - Estado: ${d['estado']} a las ${DateFormat('HH:mm').format(DateTime.parse(d['fecha_hora']).toLocal())}";
        })
        .join('\n');
  }

  // Motor inteligente local en Dart integrado a la BD (Para funcionar 100% offline/sin clave)
  Future<String> _getLocalResponse(String text) async {
    // Simulamos un delay de escritura humana de 1 segundo
    await Future.delayed(const Duration(milliseconds: 900));

    final query = text.toLowerCase();

    // 1. PREGUNTAS SOBRE MEDICAMENTOS
    if (query.contains('medicamento') ||
        query.contains('remedio') ||
        query.contains('pastilla')) {
      if (_medicamentos.isEmpty) {
        return 'Actualmente no tienes medicamentos registrados en tu inventario o tratamientos activos. ¿Te gustaría que te ayude a crear uno en la sección "Medicamento"?';
      }
      final list = _medicamentos
          .map(
            (m) =>
                '• *${m['nombre']}* (${m['dosis'] ?? "Sin dosis especificada"}) cada ${m['frecuencia_horas']} horas.',
          )
          .join('\n');
      return 'Aquí tienes la lista de tus medicamentos registrados actualmente:\n\n$list\n\n¿Quieres saber los horarios específicos de alguno de ellos?';
    }

    // 2. PREGUNTAS SOBRE DOSIS U HORARIOS
    if (query.contains('dosis') ||
        query.contains('horario') ||
        query.contains('hora') ||
        query.contains('hoy') ||
        query.contains('toca')) {
      final hoy = DateTime.now();
      final dosisHoy = _dosis.where((d) {
        if (d['fecha_hora'] == null) return false;
        final f = DateTime.parse(d['fecha_hora']).toLocal();
        return f.year == hoy.year && f.month == hoy.month && f.day == hoy.day;
      }).toList();

      if (dosisHoy.isEmpty) {
        return 'No tienes ninguna dosis programada o registrada para el día de hoy en tu calendario. Asegúrate de tener tratamientos activos creados.';
      }

      dosisHoy.sort(
        (a, b) =>
            a['fecha_hora'].toString().compareTo(b['fecha_hora'].toString()),
      );

      final list = dosisHoy
          .map((d) {
            final med = _medicamentos.firstWhere(
              (m) => m['id'].toString() == d['medicamento_id'].toString(),
              orElse: () => {'nombre': 'Medicamento'},
            );
            final hora = DateFormat(
              'hh:mm a',
            ).format(DateTime.parse(d['fecha_hora']).toLocal());
            String estadoEmoji = '⏳';
            if (d['estado'] == 'tomada') estadoEmoji = '✅';
            if (d['estado'] == 'omitida') estadoEmoji = '❌';
            if (d['estado'] == 'tarde') estadoEmoji = '⏰';

            return '$estadoEmoji *${med['nombre']}* a las $hora (Estado: ${d['estado']})';
          })
          .join('\n');

      return 'Este es tu cronograma de dosis para hoy:\n\n$list\n\n¿Quieres registrar alguna dosis como tomada? Puedes hacerlo directamente en la pestaña "Dosis".';
    }

    // 3. PREGUNTAS SOBRE DIETA
    if (query.contains('dieta') ||
        query.contains('comer') ||
        query.contains('comida') ||
        query.contains('alimento')) {
      if (_dietas.isEmpty) {
        return 'No tienes dietas registradas asociadas a tus tratamientos activos. Recuerda que puedes planificar tus dietas médicas en la pestaña "Dieta".';
      }
      final list = _dietas
          .map(
            (d) =>
                '• *${d['descripcion']}* (Del ${d['fecha_inicio'] ?? "Inicio"} al ${d['fecha_fin'] ?? "Fin"})',
          )
          .join('\n');
      return 'Aquí tienes tus especificaciones de dietas activas:\n\n$list\n\n¿Necesitas recomendaciones saludables para acompañar tu plan alimenticio?';
    }

    // 4. PREGUNTAS SOBRE INVENTARIO / STOCK
    if (query.contains('inventario') ||
        query.contains('stock') ||
        query.contains('cantidad') ||
        query.contains('falta') ||
        query.contains('caja')) {
      try {
        final listTratIds = _tratamientos
            .map((t) => t['id'].toString())
            .toList();
        if (listTratIds.isNotEmpty) {
          final listMedIds = _medicamentos
              .map((m) => m['id'].toString())
              .toList();
          if (listMedIds.isNotEmpty) {
            final invRes = await _supabase
                .from('inventario')
                .select()
                .inFilter('medicamento_id', listMedIds);
            final inventarios = List<Map<String, dynamic>>.from(invRes);

            if (inventarios.isEmpty) {
              return 'No tienes registros de stock en tu inventario actualmente.';
            }

            final list = inventarios
                .map((inv) {
                  final med = _medicamentos.firstWhere(
                    (m) =>
                        m['id'].toString() == inv['medicamento_id'].toString(),
                    orElse: () => {'nombre': 'Medicamento'},
                  );
                  final actual = inv['cantidad_actual'] ?? 0;
                  final inicial = inv['cantidad_inicial'] ?? 0;
                  final alerta = inv['alerta_minima'] ?? 5;
                  final aviso = actual <= alerta
                      ? '⚠️ ¡Queda poco!'
                      : '✅ Suficiente';

                  return '• *${med['nombre']}*: $actual/$inicial unidades ($aviso)';
                })
                .join('\n');

            return 'Este es el balance actual de tu inventario de medicamentos:\n\n$list\n\n¿Quieres actualizar el stock inicial de algún medicamento? Hazlo desde la sección "Inventario".';
          }
        }
      } catch (_) {}
      return 'No pude recuperar los detalles exactos del inventario. Pero puedes verlos actualizados en tiempo real en tu pantalla de "Inventario".';
    }

    // 5. SALUDOS O INTRODUCCIÓN
    if (query.contains('hola') ||
        query.contains('buenos dias') ||
        query.contains('buenas tardes') ||
        query.contains('buenas noches')) {
      return '¡Hola de nuevo, ${widget.userName}! ¿Cómo te sientes hoy? Estoy aquí para ayudarte a llevar el control de tus medicamentos, recordatorios y brindarte consejos útiles.';
    }

    // 6. AGRADECIMIENTOS
    if (query.contains('gracias') ||
        query.contains('buenisimo') ||
        query.contains('perfecto') ||
        query.contains('ok')) {
      return '¡De nada! Es un placer ayudarte. Recuerda que mantener la constancia en tus tratamientos es vital para tu bienestar. ¿Hay algo más en lo que te pueda asistir?';
    }

    // 7. RESPUESTA POR DEFECTO PARA PREGUNTAS GENERALES DE SALUD
    return 'Entiendo tu duda. Como asistente inteligente local de Dosify, puedo guiarte con exactitud sobre la información registrada en la app (medicamentos, dosis del día, dietas e inventario).\n\n💡 *Tip de salud:* Recuerda mantenerte hidratado (al menos 2 litros de agua diarios) y tomar tus pastillas a la hora programada para asegurar la efectividad del tratamiento. Si tienes preguntas de diagnóstico médico avanzado, te sugiero activar el *Modo Gemini* en la esquina superior derecha o consultar directamente con tu médico.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showApiKeyDialog() {
    final ctrl = TextEditingController(text: _geminiApiKey);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar API Key de Gemini'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa tu clave de API de Gemini para habilitar el motor conversacional inteligente y libre de Dosify AI.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: ctrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Gemini API Key',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00ACC1),
            ),
            onPressed: () async {
              final newKey = ctrl.text.trim();
              setState(() {
                _geminiApiKey = newKey;
              });
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('gemini_api_key', newKey);
              } catch (e) {
                debugPrint('Error al guardar la clave API: $e');
              }
              if (mounted) {
                Navigator.pop(context);
                // Usamos el ScaffoldMessenger del widget padre (no del dialog)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      newKey.isEmpty
                          ? 'Modo Local restablecido.'
                          : '¡Modo Gemini activado con éxito! 🧠',
                    ),
                    backgroundColor: const Color(0xFF00ACC1),
                  ),
                );
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF00ACC1);
    const Color textCyan = Color(0xFF006064);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // --- HEADER DEL ASISTENTE ---
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: primaryCyan.withOpacity(0.1),
                          child: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: primaryCyan,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Asistente de IA',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textCyan,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _geminiApiKey.isEmpty
                                        ? Colors.blue
                                        : Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _geminiApiKey.isEmpty
                                      ? 'Motor Local (Conectado)'
                                      : 'Modo Gemini Activo',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: primaryCyan,
                      ),
                      tooltip: 'Configurar IA',
                      onPressed: _showApiKeyDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- LISTA DE MENSAJES ---
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          // Burbuja de cargando/escribiendo
                          return _buildTypingBubble(primaryCyan);
                        }

                        final msg = _messages[index];
                        final isUser = msg['isUser'] as bool;
                        return _buildChatBubble(
                          msg['text'],
                          isUser,
                          msg['time'],
                          primaryCyan,
                          textCyan,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- BARRA DE ENTRADA ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'Pregúntame lo que quieras...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: primaryCyan,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(
    String text,
    bool isUser,
    String time,
    Color activeColor,
    Color textCyan,
  ) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: isUser ? activeColor : const Color(0xFFF1F9F9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(isUser ? 15 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: TextStyle(
                  color: isUser ? Colors.white70 : Colors.grey,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingBubble(Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: const BoxDecoration(
          color: Color(0xFFF1F9F9),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(color: color, strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            const Text(
              'Pensando...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
