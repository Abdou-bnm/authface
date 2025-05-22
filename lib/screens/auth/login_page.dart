import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/constants.dart';
import '../../widgets/show_snackbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _localAuth = LocalAuthentication();
  bool _loading = false;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      setState(() {
        _isBiometricAvailable = canCheckBiometrics && isDeviceSupported;
      });
    } catch (e) {
      setState(() {
        _isBiometricAvailable = false;
      });
    }
  }

  Future<void> _loginWithFaceId() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to sign in',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        // Here you would typically verify the user's identity with your backend
        // For now, we'll just show a success message
        showSnackBar(context, "Face ID authentication successful!");
        GoRouter.of(context).go('/home');
      }
    } catch (e) {
      showSnackBar(context, "Face ID authentication failed: $e", isError: true);
    }
  }

  void _loginWithEmail() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.length < 6) {
      showSnackBar(context, "Enter valid credentials", isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final isVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      if (!isVerified) {
        await FirebaseAuth.instance.signOut();
        showSnackBar(
          context,
          "Verify your email before logging in",
          isError: true,
        );
      } else {
        GoRouter.of(context).go('/home');
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message ?? "Login failed", isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      GoRouter.of(context).go('/home');
    } catch (e) {
      showSnackBar(context, "Google login failed: $e", isError: true);
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
                const Text('Sign In', style: Constants.headingStyle),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Constants.accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Constants.accentColor,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        GoRouter.of(context).push('/forgot-password'),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Constants.accentColor),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loginWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.accentColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Sign In'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'or continue with',
                  style: TextStyle(color: Constants.accentColor),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: Image.asset('assets/images/google.png', height: 20),
                  label: const Text(
                    "Sign in with Google",
                    style: TextStyle(color: Constants.accentColor),
                  ),
                  onPressed: _loginWithGoogle,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: Constants.accentColor),
                  ),
                ),
                if (_isBiometricAvailable) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.face, color: Constants.accentColor),
                    label: const Text(
                      "Sign in with Face ID",
                      style: TextStyle(color: Constants.accentColor),
                    ),
                    onPressed: _loginWithFaceId,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      side: const BorderSide(color: Constants.accentColor),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => GoRouter.of(context).go('/signup'),
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: Constants.accentColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
