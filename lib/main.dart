import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Asegúrate de que estas rutas coincidan con tus nombres de archivo exactos
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';

void main() async {
  // 1. Inicialización obligatoria
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Conexión a Supabase
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dosify',
      theme: ThemeData(
        // Color turquesa de tu logo
        primaryColor: const Color(0xFF00ACC1),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00ACC1)),
        useMaterial3: true,
      ),
      // Iniciamos directo en Login para tus capturas
      home: const LoginScreen(), 
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainNavigation(),
      },
    );
  }
}