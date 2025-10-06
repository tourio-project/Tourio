import 'package:flutter/material.dart';

class ObscuredTextField extends StatefulWidget {
  const ObscuredTextField({
    required this.controller,
    required this.label,
    this.textColor,
    this.fill,
    this.validator,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final Color? textColor;
  final Color? fill;
  final String? Function(String?)? validator;

  @override
  State<ObscuredTextField> createState() => _ObscuredTextFieldState();
}

class _ObscuredTextFieldState extends State<ObscuredTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      style: TextStyle(color: widget.textColor),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: widget.textColor != null
            ? TextStyle(color: widget.textColor!.withOpacity(0.8))
            : null,
        fillColor: widget.fill,
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          color: widget.textColor ?? Colors.black87,
        ),
      ),
    );
  }
}