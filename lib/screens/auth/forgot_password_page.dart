import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../widgets/show_snackbar.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();

    Future<void> sendResetLink() async {
      final email = emailCtrl.text.trim();
      if (!email.contains('@')) {
        showSnackBar(context, 'Enter a valid email address', isError: true);
        return;
      }

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        showSnackBar(context, 'Reset link sent. Check your inbox!');
        GoRouter.of(context).go('/login');
      } catch (e) {
        showSnackBar(context, 'Failed to send reset email: $e', isError: true);
      }
    }

    return Scaffold(
      backgroundColor: Constants.primaryColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_reset, size: 64, color: Constants.accentColor),
                const SizedBox(height: 20),
                const Text('Forgot Password?', style: Constants.headingStyle),
                const SizedBox(height: 12),
                const Text(
                  'Enter your email to receive a password reset link.',
                  textAlign: TextAlign.center,
                  style: Constants.labelStyle,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined, color: Constants.accentColor),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: sendResetLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.accentColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Send Reset Link'),
                ),
                TextButton(
                  onPressed: () => GoRouter.of(context).go('/login'),
                  child: const Text('Back to Login', style: TextStyle(color: Constants.accentColor)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
