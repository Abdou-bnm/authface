import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../widgets/show_snackbar.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  Future<void> _checkVerification(BuildContext context) async {
    await FirebaseAuth.instance.currentUser?.reload();
    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      showSnackBar(context, 'Email verified!');
      GoRouter.of(context).go('/home');
    } else {
      showSnackBar(context, 'Email not verified yet.', isError: true);
    }
  }

  Future<void> _resendVerificationEmail(BuildContext context) async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      showSnackBar(context, 'Verification email resent!');
    } catch (e) {
      showSnackBar(context, 'Error sending verification: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const Icon(Icons.mark_email_read_outlined, size: 64, color: Constants.accentColor),
                const SizedBox(height: 20),
                const Text('Verify Your Email', style: Constants.headingStyle),
                const SizedBox(height: 12),
                const Text(
                  'Please verify your email address to continue.',
                  textAlign: TextAlign.center,
                  style: Constants.labelStyle,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _checkVerification(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.accentColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('I Verified'),
                ),
                TextButton(
                  onPressed: () => _resendVerificationEmail(context),
                  child: const Text('Resend Email', style: TextStyle(color: Constants.accentColor)),
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
