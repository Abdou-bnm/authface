import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../services/face_embedding_service.dart';
import '../../services/firestore_service.dart';
import '../../core/constants.dart';
import '../../widgets/show_snackbar.dart';

class FaceScanPage extends StatefulWidget {
  final String userId;

  const FaceScanPage({super.key, required this.userId});

  @override
  State<FaceScanPage> createState() => _FaceScanPageState();
}

class _FaceScanPageState extends State<FaceScanPage> {
  final ImagePicker _picker = ImagePicker();
  final FaceEmbeddingService _embeddingService = FaceEmbeddingService();
  final FirestoreService _firestoreService = FirestoreService();

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );

  File? _scannedImage;
  bool _loading = false;
  double? _similarity;

  @override
  void initState() {
    super.initState();
    _embeddingService.loadModel(); // Load TFLite model before usage
  }

  @override
  void dispose() {
    _embeddingService.dispose(); // Clean up interpreter
    super.dispose();
  }

  Future<void> _scanAndCompare() async {
    final XFile? imageFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (imageFile == null) return;

    setState(() {
      _loading = true;
      _scannedImage = File(imageFile.path);
      _similarity = null;
    });

    try {
      final inputImage = InputImage.fromFile(_scannedImage!);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        showSnackBar(context, 'No face detected.', isError: true);
        return;
      }

      final currentEmbedding = await _embeddingService.extractEmbedding(_scannedImage!);
      final storedEmbedding = await _firestoreService.getEmbeddingByUid(widget.userId);

      final similarity = _embeddingService.compareEmbeddings(currentEmbedding, storedEmbedding);


      if (!mounted) return;

      setState(() => _similarity = similarity);

      if (similarity >= 0.7) {
        showSnackBar(context, '✅ Face matched! (Similarity: ${(similarity * 100).toStringAsFixed(2)}%)');
      } else {
        showSnackBar(context, '❌ Face does not match. (Similarity: ${(similarity * 100).toStringAsFixed(2)}%)', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, 'Error during face scan: $e', isError: true);
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
        title: const Text('Face Scan', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _scanAndCompare,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('📸 Scan & Compare'),
            ),
            const SizedBox(height: 20),
            if (_scannedImage != null) ...[
              const Text('Scanned Image:'),
              const SizedBox(height: 10),
              Image.file(_scannedImage!, height: 200),
              const SizedBox(height: 10),
              if (_similarity != null)
                Text(
                  _similarity! >= 0.7
                      ? '✅ Match (${(_similarity! * 100).toStringAsFixed(2)}%)'
                      : '❌ No Match (${(_similarity! * 100).toStringAsFixed(2)}%)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _similarity! >= 0.7 ? Colors.green : Colors.red,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
