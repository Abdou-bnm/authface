import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../services/face_embedding_service.dart';
import '../../services/firestore_service.dart';
import '../../core/constants.dart';
import '../../widgets/show_snackbar.dart';

class FaceEnrollPage extends StatefulWidget {
  final String userId;
  final String email;

  const FaceEnrollPage({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  State<FaceEnrollPage> createState() => _FaceEnrollPageState();
}

class _FaceEnrollPageState extends State<FaceEnrollPage> {
  final ImagePicker _picker = ImagePicker();
  final FaceEmbeddingService _embeddingService = FaceEmbeddingService();
  final FirestoreService _firestoreService = FirestoreService();

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );

  File? _capturedImage;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _embeddingService.loadModel(); // Load the model on screen init
  }

  @override
  void dispose() {
    _embeddingService.dispose(); // Dispose model when screen is closed
    super.dispose();
  }

  Future<void> _enrollFace() async {
    final XFile? imageFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (imageFile == null) return;

    setState(() {
      _loading = true;
      _capturedImage = File(imageFile.path);
    });

    try {
      final inputImage = InputImage.fromFile(_capturedImage!);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        showSnackBar(context, 'No face detected', isError: true);
        return;
      }

      final embedding = await _embeddingService.extractEmbedding(_capturedImage!);

      await _firestoreService.saveUser(
        uid: widget.userId,
        email: widget.email,
        embedding: embedding,
      );

      if (!mounted) return;
      showSnackBar(context, '✅ Face enrolled successfully!');
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, '❌ Enrollment failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.primaryColor,
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        elevation: 0,
        title: const Text('Enroll Face', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _enrollFace,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('📷 Enroll Face'),
            ),
            const SizedBox(height: 20),
            if (_capturedImage != null) ...[
              const Text('Captured Image:'),
              const SizedBox(height: 10),
              Image.file(_capturedImage!, height: 200),
            ]
          ],
        ),
      ),
    );
  }
}
