import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool loading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: loading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }
}
