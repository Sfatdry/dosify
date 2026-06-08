import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    // After the animation, navigate based on auth state.
    Future.delayed(const Duration(seconds: 3), _navigateBasedOnAuth);
  }

  void _navigateBasedOnAuth() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      // User already logged in, go to main navigation.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainNavigation(
            userName:
                session.user.userMetadata?['full_name'] ??
                session.user.email?.split('@')[0] ??
                'Usuario',
            userId: session.user.id,
          ),
        ),
      );
    } else {
      // No active session, go to login screen.
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.local_hospital_rounded,
                size: 120,
                color: Color(0xFF00ACC1),
              ),
              SizedBox(height: 20),
              Text(
                'Dosify',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00ACC1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
