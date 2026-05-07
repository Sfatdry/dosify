import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow; // Ocultamos los de Flutter
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart'; // Usamos los de la librería

class NeumorphicInput extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;

  // Corregimos el constructor (quitamos el error del const)
  const NeumorphicInput({
    super.key, // Usamos super.key para Flutter moderno
    required this.hintText,
    required this.icon,
    required this.controller,
    this.isPassword = false,
  });

  @override
  State<NeumorphicInput> createState() => _NeumorphicInputState();
}

class _NeumorphicInputState extends State<NeumorphicInput> {
  bool _isPressed = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Focus( // Cambiado a Focus para detectar cuando el usuario escribe
      onFocusChange: (hasFocus) {
        setState(() => _isPressed = hasFocus);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2F1),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              blurRadius: _isPressed ? 5 : 10,
              offset: _isPressed ? const Offset(5, 5) : const Offset(6, 6),
              color: Colors.black.withOpacity(0.1),
              inset: _isPressed, // Esto es lo que causaba el error
            ),
            BoxShadow(
              blurRadius: _isPressed ? 5 : 10,
              offset: _isPressed ? const Offset(-5, -5) : const Offset(-6, -6),
              color: Colors.white.withOpacity(0.8),
              inset: _isPressed,
            ),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: Icon(widget.icon, color: const Color(0xFF2B889C)),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }
}