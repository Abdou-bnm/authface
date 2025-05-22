import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> _pickImage(int index) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (index == 1) {
          _image1 = File(picked.path);
        } else {
          _image2 = File(picked.path);
        }
        _similarity = null;
      });
    }
  }

  Future<void> _compareFaces() async {
    if (_image1 == null || _image2 == null) {
      showSnackBar(context, "Select both images", isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final emb1 = await _embeddingService.extractEmbedding(_image1!);
      final emb2 = await _embeddingService.extractEmbedding(_image2!);
      final similarity = _cosineSimilarity(emb1, emb2) * 100;

      setState(() {
        _similarity = similarity;
      });

      final msg = similarity >= 70
          ? "✅ Match Success (${similarity.toStringAsFixed(2)}%)"
          : "❌ Not a Match (${similarity.toStringAsFixed(2)}%)";

      showSnackBar(context, msg, isError: similarity < 70);
    } catch (e) {
      showSnackBar(context, "Error comparing faces: $e", isError: true);
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
      backgroundColor: Constants.primaryColor,
      appBar: AppBar(
        title: const Text("Face Compare"),
        backgroundColor: Constants.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildImageCard(1, _image1)),
                const SizedBox(width: 16),
                Expanded(child: _buildImageCard(2, _image2)),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.compare),
              label: Text(_loading ? "Comparing..." : "Compare Faces"),
              onPressed: _loading ? null : _compareFaces,
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.accentColor,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 24),
            if (_similarity != null)
              Text(
                _similarity! >= 70
                    ? "✅ Match: ${_similarity!.toStringAsFixed(2)}%"
                    : "❌ Not a Match: ${_similarity!.toStringAsFixed(2)}%",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _similarity! >= 70 ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(int index, File? image) {
    return GestureDetector(
      onTap: () => _pickImage(index),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Constants.accentColor),
          borderRadius: BorderRadius.circular(12),
          color: Constants.accentColor.withOpacity(0.05),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(image, fit: BoxFit.cover),
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_a_photo, size: 32, color: Constants.accentColor),
                    const SizedBox(height: 8),
                    Text("Pick Face $index", style: TextStyle(color: Constants.accentColor)),
                  ],
                ),
              ),
      ),
    );
  }
}
