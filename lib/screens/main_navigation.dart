import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'asistente_ia_screen.dart';
import 'profile_screen.dart';
import 'tratamiento_screen.dart';
import 'inventory_screen.dart';
import 'recordatorio_screen.dart';
import 'medicamento_screen.dart';
import 'dosis_screen.dart';
import 'dieta_screen.dart';
import 'nota_de_voz_screen.dart';
import 'farmacia_screen.dart';
import 'historial_screen.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MainNavigation extends StatefulWidget {
  final String userName;
  final String userId;
  const MainNavigation({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  late List<Widget>
  _screens; // <-- Déjalo exactamente así, con 'late' y sin 'const'
  final ScrollController _scrollController =
      ScrollController(); // Controlador para la barrita deslizable

  Timer? _reminderTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Set<String> _rungRemindersToday = {};
  List<Map<String, dynamic>> _cachedReminders = [];
  DateTime? _lastCacheRefresh;

  // DENTRO DE TU MAIN_NAVIGATION.DART
  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _startReminderTimer();

    _screens = [
      DashboardScreen(userName: widget.userName, userId: widget.userId),
      AsistenteIaScreen(userName: widget.userName, userId: widget.userId),
      ProfileScreen(userId: widget.userId),
      TratamientoScreen(userName: widget.userName, userId: widget.userId),
      HistorialScreen(userName: widget.userName, userId: widget.userId),
      MedicamentoScreen(userName: widget.userName, userId: widget.userId),
      DosisScreen(userName: widget.userName, userId: widget.userId),
      RecordatorioScreen(userName: widget.userName, userId: widget.userId),
      InventoryScreen(
        userName: widget.userName,
        userId: widget.userId,
        onVerFarmacias: () => setState(() => _selectedIndex = 11),
      ),
      DietaScreen(userName: widget.userName, userId: widget.userId),
      NotaDeVozScreen(userName: widget.userName, userId: widget.userId),
      FarmaciaScreen(userName: widget.userName, userId: widget.userId),
    ];
  }

  final List<Map<String, dynamic>> _menuItems = [
    {'label': 'Dashboard', 'icon': Icons.grid_view_rounded},
    {'label': 'Asistente IA', 'icon': Icons.chat_bubble_outline_rounded},
    {'label': 'Usuario', 'icon': Icons.person_outline_rounded},
    {'label': 'Tratamiento', 'icon': Icons.assignment_outlined},
    {'label': 'Historial', 'icon': Icons.bar_chart_rounded},
    {'label': 'Medicamento', 'icon': Icons.link_rounded},
    {'label': 'Dosis', 'icon': Icons.check_circle_outline_rounded},
    {'label': 'Recordatorio', 'icon': Icons.notifications_none_rounded},
    {'label': 'Inventario', 'icon': Icons.archive_outlined},
    {'label': 'Dieta', 'icon': Icons.restaurant_rounded},
    {'label': 'Nota de Voz', 'icon': Icons.mic_none_rounded},
    {'label': 'Farmacia', 'icon': Icons.local_pharmacy_rounded},
  ];

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 150,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 150,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _requestPermissions() async {
    try {
      final status = await Permission.microphone.status;
      if (!status.isGranted) {
        await Permission.microphone.request();
      }
      
      final notifStatus = await Permission.notification.status;
      if (!notifStatus.isGranted) {
        await Permission.notification.request();
      }

      final alarmStatus = await Permission.scheduleExactAlarm.status;
      if (!alarmStatus.isGranted) {
        await Permission.scheduleExactAlarm.request();
      }
    } catch (e) {
      debugPrint("Error requesting permissions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String initial = widget.userName.isNotEmpty
        ? widget.userName[0].toUpperCase()
        : "A";

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // --- HEADER PRINCIPAL ÚNICO ---
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 15 : 30,
              vertical: isMobile ? 10 : 15,
            ),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00ACC1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.local_hospital_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dosify",
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 22,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF006064),
                              ),
                            ),
                            if (!isMobile)
                              const Text(
                                "Control inteligente de medicamentos",
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMobile)
                              const Text(
                                "Bienvenida",
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            Text(
                              widget.userName,
                              style: TextStyle(
                                fontSize: isMobile ? 13 : 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF006064),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: isMobile ? 15 : 18,
                        backgroundColor: const Color(0xFF00C853),
                        child: Text(
                          initial,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 12 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- BARRA DE MENÚ CON TAMAÑO NORMAL, SCROLL Y BOTONES DE GUÍA ---
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: Color(0xFF64748B),
                  ),
                  onPressed: _scrollLeft,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: List.generate(_menuItems.length, (index) {
                          bool isSelected = _selectedIndex == index;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedIndex = index),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 5,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF00ACC1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _menuItems[index]['icon'],
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _menuItems[index]['label'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF64748B),
                  ),
                  onPressed: _scrollRight,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // --- CONTENIDO VARIABLE ---
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  void _startReminderTimer() {
    _reminderTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _checkActiveReminders();
    });
  }

  Future<void> _refreshReminderCache() async {
    try {
      // 1. Obtener tratamientos del usuario
      final trats = await Supabase.instance.client
          .from('tratamiento')
          .select('id')
          .eq('usuario_id', widget.userId);
      final treatmentIds = trats.map((t) => t['id'].toString()).toList();

      if (treatmentIds.isEmpty) {
        _cachedReminders = [];
        _lastCacheRefresh = DateTime.now();
        return;
      }

      // 2. Obtener medicamentos de esos tratamientos
      final meds = await Supabase.instance.client
          .from('medicamento')
          .select('id, nombre, dosis')
          .inFilter('tratamiento_id', treatmentIds);

      if (meds.isEmpty) {
        _cachedReminders = [];
        _lastCacheRefresh = DateTime.now();
        return;
      }

      final listMedIds = meds.map((m) => m['id'].toString()).toList();

      // 3. Buscar recordatorios activos para esos medicamentos
      final recs = await Supabase.instance.client
          .from('recordatorio')
          .select('id, fecha_hora, activo, medicamento_id')
          .eq('activo', true)
          .inFilter('medicamento_id', listMedIds);

      final List<Map<String, dynamic>> enriched = [];
      for (var r in recs) {
        final med = meds.firstWhere(
          (m) => m['id'].toString() == r['medicamento_id'].toString(),
          orElse: () => {'nombre': 'Medicamento', 'dosis': ''},
        );
        enriched.add({
          'id': r['id'],
          'fecha_hora': r['fecha_hora'],
          'medicamento_id': r['medicamento_id'],
          'nombre_med': med['nombre'],
          'dosis': med['dosis'],
        });
      }

      _cachedReminders = enriched;
      _lastCacheRefresh = DateTime.now();
    } catch (e) {
      debugPrint('Error al actualizar caché de recordatorios: $e');
    }
  }

  void _checkActiveReminders() async {
    final ahora = DateTime.now();

    if (_lastCacheRefresh == null ||
        ahora.difference(_lastCacheRefresh!) > const Duration(minutes: 1)) {
      await _refreshReminderCache();
    }

    for (var rec in _cachedReminders) {
      if (rec['fecha_hora'] == null) continue;
      try {
        final scheduledTime = DateTime.parse(rec['fecha_hora']).toLocal();

        if (ahora.hour == scheduledTime.hour &&
            ahora.minute == scheduledTime.minute) {
          final String rungKey =
              "${rec['id']}_${ahora.year}_${ahora.month}_${ahora.day}_${ahora.hour}_${ahora.minute}";
          if (!_rungRemindersToday.contains(rungKey)) {
            _rungRemindersToday.add(rungKey);
            _triggerAlert(rec);
          }
        }
      } catch (e) {
        debugPrint('Error al verificar recordatorio: $e');
      }
    }
  }

  void _triggerAlert(Map<String, dynamic> rec) async {
    try {
      await _audioPlayer.play(AssetSource('sounds/notification.wav'));
    } catch (e) {
      debugPrint('Error al reproducir sonido: $e');
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F7FA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.alarm_on_rounded,
                    color: Color(0xFF00ACC1),
                    size: 50,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  '¡Hora de tu Medicamento! 💊',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006064),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'Es momento de tomar:\n'),
                      TextSpan(
                        text: '${rec['nombre_med']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00ACC1),
                          fontSize: 18,
                        ),
                      ),
                      if (rec['dosis'] != null &&
                          rec['dosis'].toString().isNotEmpty) ...[
                        const TextSpan(text: '\nDosis: '),
                        TextSpan(
                          text: '${rec['dosis']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00ACC1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await _registerDoseStatus(
                            rec['medicamento_id'].toString(),
                            'tomada',
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle_rounded),
                            SizedBox(width: 10),
                            Text(
                              'Marcar como tomada ✅',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.redAccent,
                            width: 1.5,
                          ),
                          foregroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await _registerDoseStatus(
                            rec['medicamento_id'].toString(),
                            'omitida',
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.close_rounded),
                            SizedBox(width: 10),
                            Text(
                              'Omitir dosis ❌',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _snoozeReminder(rec);
                        },
                        child: const Text(
                          'Posponer 5 minutos ⏰',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _registerDoseStatus(String medId, String status) async {
    try {
      final String dosisId = const Uuid().v4();
      await Supabase.instance.client.from('dosis').insert({
        'id': dosisId,
        'medicamento_id': medId,
        'fecha_hora': DateTime.now().toIso8601String(),
        'estado': status,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'tomada'
                  ? '¡Dosis registrada como tomada! 💪'
                  : 'Dosis registrada como omitida.',
            ),
            backgroundColor: status == 'tomada' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al registrar estado de dosis: $e');
    }
  }

  void _snoozeReminder(Map<String, dynamic> rec) {
    final snoozeTime = DateTime.now().add(const Duration(minutes: 5));

    final snoozedRec = {
      'id': '${rec['id']}_snooze',
      'fecha_hora': snoozeTime.toIso8601String(),
      'medicamento_id': rec['medicamento_id'],
      'nombre_med': rec['nombre_med'],
      'dosis': rec['dosis'],
    };

    setState(() {
      _cachedReminders.add(snoozedRec);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Recordatorio pospuesto a las ${DateFormat('hh:mm a').format(snoozeTime)} ⏰',
        ),
        backgroundColor: const Color(0xFF00ACC1),
      ),
    );
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
