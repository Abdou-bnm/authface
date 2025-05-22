import 'package:flutter/material.dart';

class Constants {
  // Primary Background Color (Futuristic white-gray)
  static const Color primaryColor = Color(0xFFF9F9FB);

  // Accent Color (Deep Slate Gray)
  static const Color accentColor = Color(0xFF4B5563);

  // Optional: Light variant for chips/borders
  static const Color lightAccent = Color(0xFF9CA3AF); // optional lighter tone

  // Text Styles (optional)
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: accentColor,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 14,
    color: accentColor,
  );

  // Firestore collections (you can expand this as needed)
  static const String usersCollection = 'users';
  static const String attendanceCollection = 'attendance';

  // FaceCheck API
  static const String faceCheckApiKey = '6aH5JxtAo5HIglpdrXxhNLMaJLDdq90duLwQRUEvyjuQcYz8Xf8tggRygBt1/CUrsxLM6Q5jt8k=';
  static const String faceCheckSearchUrl = 'https://api.facecheck.id/v1/search';
  static const String faceCheckEnrollUrl = 'https://api.facecheck.id/v1/enroll';
}
