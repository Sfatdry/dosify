import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- CORREGIDO AQUÍ: Sintaxis correcta de Dart con parámetros nombrados y strings ('') ---
  await Supabase.initialize(
    url: 'https://qqhyyzlanjuczuddszym.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFxaHl5emxhbmp1Y3p1ZGRzenltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc0NjIwNjksImV4cCI6MjA5MzAzODA2OX0.QaXBaYH-UJyx_ZBpOLPdgQkKOCa9Imz4Rq6k5KQGK6I',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos la sesión actual del usuario en Supabase
    final session = Supabase.instance.client.auth.currentSession;
    
    // Si hay sesión, extraemos su nombre de los metadatos o su correo; si no, dejamos un valor por defecto
    final String currentUserName = session?.user.userMetadata?['full_name'] ?? 
                                   session?.user.email?.split('@')[0] ?? 
                                   "Usuario";

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
      // --- CONTROL INTELIGENTE DE INICIO ---
      // Si ya está logueado, va directo al Home; si no, muestra el Login
      home: session != null 
          ? MainNavigation(userName: currentUserName) 
          : const LoginScreen(), 
          
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => MainNavigation(userName: currentUserName), 
      },
    );
  }
}