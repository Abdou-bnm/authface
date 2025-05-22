import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // make sure flutterfire configure created this
import 'routes.dart';
import 'core/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Face Recognition Attendance',
      routerConfig: AppRouter.router,
      theme: ThemeData(
        scaffoldBackgroundColor: Constants.primaryColor,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Constants.accentColor),
        useMaterial3: true,
      ),
    );
  }
}
