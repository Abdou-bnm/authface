import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/show_snackbar.dart';
import '../../core/constants.dart';

class FallbackPasswordLoginPage extends StatefulWidget {
  const FallbackPasswordLoginPage({super.key});

  @override
  State<FallbackPasswordLoginPage> createState() => _FallbackPasswordLoginPageState();
}

class _FallbackPasswordLoginPageState extends State<FallbackPasswordLoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.length < 6) {
      showSnackBar(context, "Enter valid credentials", isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      GoRouter.of(context).go('/home');
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message ?? "Login failed", isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.primaryColor,
      appBar: AppBar(
        title: const Text("Login with Password"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Constants.accentColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text("Enter your email and password to log in.",
                  style: Constants.labelStyle, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.accentColor,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              TextButton(
                onPressed: () => GoRouter.of(context).go('/login'),
                child: const Text("Back to Face ID"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
