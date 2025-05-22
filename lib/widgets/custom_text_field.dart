import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final String? Function(String?)? validator;
  final Widget? suffixIcon; // ✅ Add this

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isPassword = false,
    this.validator,
    this.suffixIcon, // ✅ Add this
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        suffixIcon: suffixIcon, // ✅ Add this
      ),
    );
  }
}
