import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:audioplayers/audioplayers.dart'; 
import '../../services/face_embedding_service.dart';
import '../../services/firestore_service.dart';
import '../../core/constants.dart';
import '../../widgets/show_snackbar.dart';

class FaceLoginPage extends StatefulWidget {
  const FaceLoginPage({super.key});

  @override
  State<FaceLoginPage> createState() => _FaceLoginPageState();
}

class _FaceLoginPageState extends State<FaceLoginPage> {
  final _emailCtrl = TextEditingController();
  final _picker = ImagePicker();
  final _embeddingService = FaceEmbeddingService();
  final _firestoreService = FirestoreService();
  final _faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableContours: true, enableClassification: true),
  );
  final AudioPlayer _audioPlayer = AudioPlayer(); // ✅ sound

  File? _capturedFace;
  bool _loading = false;
  double? _similarity;
  bool _isMatch = false;

  @override
  void initState() {
    super.initState();
    _embeddingService.loadModel();
  }

  Future<void> _captureFace() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    setState(() {
      _capturedFace = File(image.path);
    });
  }

  Future<void> _signInWithFace() async {
    final email = _emailCtrl.text.trim();

    if (email.isEmpty || _capturedFace == null) {
      showSnackBar(context, "Enter email and capture a face image", isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final userData = await _firestoreService.getUserByEmail(email);
      final storedEmbedding = userData['embedding'];

      final inputImage = InputImage.fromFile(_capturedFace!);
      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isEmpty) {
        showSnackBar(context, "No face detected. Try again.", isError: true);
        return;
      }

      final capturedEmbedding = await _embeddingService.extractEmbedding(_capturedFace!);

      final similarity = _cosineSimilarity(storedEmbedding, capturedEmbedding) * 100;
      final isMatch = similarity >= 70;

      setState(() {
        _similarity = similarity;
        _isMatch = isMatch;
      });

      if (isMatch) {
        await _audioPlayer.play(AssetSource('sounds/success.mp3')); // ✅ success sound
        showSnackBar(context, "✅ Face match: ${similarity.toStringAsFixed(2)}%", isError: false);
        GoRouter.of(context).go('/home');
      } else {
        await _audioPlayer.play(AssetSource('sounds/fail.mp3')); // ❌ fail sound
        showSnackBar(context, "❌ Face does not match (${similarity.toStringAsFixed(2)}%)", isError: true);
      }
    } catch (e) {
      await _audioPlayer.play(AssetSource('sounds/fail.mp3')); // ❌ fail sound
      showSnackBar(context, "Error: $e", isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  double _cosineSimilarity(List<dynamic> v1, List<dynamic> v2) {
    double dot = 0, normA = 0, normB = 0;
    for (int i = 0; i < v1.length; i++) {
      dot += v1[i] * v2[i];
      normA += v1[i] * v1[i];
      normB += v2[i] * v2[i];
    }
    return dot / (sqrt(normA) * sqrt(normB));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign In with Face ID")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _captureFace,
              child: const Text("Capture Face"),
            ),
            if (_capturedFace != null) ...[
              const SizedBox(height: 16),
              Image.file(_capturedFace!, height: 180),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _signInWithFace,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Sign In with Face"),
            ),
            if (_similarity != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _isMatch
                      ? "✅ Match: ${_similarity!.toStringAsFixed(2)}%"
                      : "❌ Not a Match: ${_similarity!.toStringAsFixed(2)}%",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isMatch ? Colors.green : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
