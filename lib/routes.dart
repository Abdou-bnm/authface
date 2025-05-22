import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/auth/login_page.dart';
import 'screens/auth/signup_page.dart';
import 'screens/auth/forgot_password_page.dart';
import 'screens/auth/verify_email_page.dart';
import 'screens/face/face_compare_page.dart';

import 'screens/home/home_page.dart';
import 'screens/auth/face_login_page.dart'; // adjust the path

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignUpPage(),
      ),
      GoRoute(
        path: '/face-login',
        builder: (context, state) => const FaceLoginPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (_, __) => const VerifyEmailPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomePage(),
      ),
      GoRoute(
        path: '/face-compare',
        builder: (_, __) => const FaceComparePage(),
      ),
    ],
  );
}
