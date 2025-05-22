import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../services/face_embedding_service.dart';
import '../../core/constants.dart';
import '../../widgets/show_snackbar.dart';

class FaceComparePage extends StatefulWidget {
  const FaceComparePage({super.key});

  @override
  State<FaceComparePage> createState() => _FaceComparePageState();
}

class _FaceComparePageState extends State<FaceComparePage> {
  final FaceEmbeddingService _embeddingService = FaceEmbeddingService();
  final _faceDetector = FaceDetector(options: FaceDetectorOptions());
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ImagePicker _picker = ImagePicker();

  File? _image1;
  File? _image2;
  double? _similarity;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _embeddingService.loadModel();
  }

  Future<void> _pickFace(int index) async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      if (index == 1) {
        _image1 = File(image.path);
      } else {
        _image2 = File(image.path);
      }
      _similarity = null;
    });
  }

  Future<void> _compareFaces() async {
    if (_image1 == null || _image2 == null) {
      showSnackBar(context, "Please select both images", isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final face1 = await _faceDetector.processImage(InputImage.fromFile(_image1!));
      final face2 = await _faceDetector.processImage(InputImage.fromFile(_image2!));

      if (face1.isEmpty || face2.isEmpty) {
        showSnackBar(context, "Face not detected in one or both images", isError: true);
        return;
      }

      final emb1Raw = await _embeddingService.extractEmbedding(_image1!);
      final emb2Raw = await _embeddingService.extractEmbedding(_image2!);

      final emb1 = List<double>.from(emb1Raw);
      final emb2 = List<double>.from(emb2Raw);

      final similarity = _cosineSimilarity(emb1, emb2) * 100;

      setState(() => _similarity = similarity);

      final match = similarity >= 70;
      await _audioPlayer.play(AssetSource(match ? 'sounds/success.mp3' : 'sounds/fail.mp3'));

      showSnackBar(
        context,
        match
            ? '✅ Match Success (${similarity.toStringAsFixed(2)}%)'
            : '❌ Not a Match (${similarity.toStringAsFixed(2)}%)',
        isError: !match,
      );
    } catch (e, stack) {
      print("Error comparing faces: $e");
      print(stack);
      await _audioPlayer.play(AssetSource('sounds/fail.mp3'));
      showSnackBar(context, "Error comparing faces: ${e.toString()}", isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  double _cosineSimilarity(List<double> v1, List<double> v2) {
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
      appBar: AppBar(title: const Text("Compare Faces")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildImageBox(_image1, () => _pickFace(1), "Face 1")),
                const SizedBox(width: 16),
                Expanded(child: _buildImageBox(_image2, () => _pickFace(2), "Face 2")),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _compareFaces,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Compare"),
            ),
            if (_similarity != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _similarity! >= 70
                      ? "✅ Match: ${_similarity!.toStringAsFixed(2)}%"
                      : "❌ Not a Match: ${_similarity!.toStringAsFixed(2)}%",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _similarity! >= 70 ? Colors.green : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBox(File? image, VoidCallback onTap, String label) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
        ),
        child: image != null
            ? Image.file(image, fit: BoxFit.cover)
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo, size: 40, color: Constants.accentColor),
                    const SizedBox(height: 8),
                    Text(label, style: const TextStyle(color: Constants.accentColor)),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _embeddingService.dispose();
    super.dispose();
  }
}
