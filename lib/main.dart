import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';
import 'package:intl/date_symbol_data_local.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://qqhyyzlanjuczuddszym.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFxaHl5emxhbmp1Y3p1ZGRzenltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc0NjIwNjksImV4cCI6MjA5MzAzODA2OX0.QaXBaYH-UJyx_ZBpOLPdgQkKOCa9Imz4Rq6k5KQGK6I',
  );
  
  await initializeDateFormatting('es', null); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. OBTENER LA SESIÓN ACTUAL INMEDIATAMENTE (Evita rebotes en recargas)
    final initialSession = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dosify',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2B889C),
          primary: const Color(0xFF2B889C),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F9F9),
      ),
      // --- NAVEGACIÓN BLINDADA CONTRA REFRESH ---
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // Usamos la sesión activa del snapshot si existe, si no, respaldamos con la sesión inicial
          final session = snapshot.data?.session ?? initialSession;

          // Si el stream está esperando pero ya detectamos que SÍ había una sesión guardada,
          // no mostramos la rueda de carga ni el login; lo mandamos directo a su pantalla.
          if (snapshot.connectionState == ConnectionState.waiting && session == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: Color(0xFF2B889C))),
            );
          }

          if (session != null) {
            // Extraer nombre del usuario de la sesión activa
            final String currentUserName = session.user.userMetadata?['full_name'] ?? 
                                           session.user.email?.split('@')[0] ?? 
                                           "Usuario";
            return MainNavigation(userName: currentUserName);
          } else {
            return const LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => MainNavigation(
          userName: Supabase.instance.client.auth.currentSession?.user.userMetadata?['full_name'] ??
                    Supabase.instance.client.auth.currentSession?.user.email?.split('@')[0] ?? 
                    "Usuario"
        ), 
      },
    );
  }
}