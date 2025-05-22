import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/face_embedding_service.dart';
import '../../core/constants.dart';
import '../../widgets/show_snackbar.dart';
import 'dart:math';

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

  Future<void> _pickFace(int faceIndex) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() {
          if (faceIndex == 1) {
            _image1 = file;
          } else {
            _image2 = file;
          }
          _similarity = null;
        });
      }
    } catch (e) {
      showSnackBar(context, "Failed to pick image: $e", isError: true);
    }
  }

  Future<void> _compareFaces() async {
    if (_image1 == null || _image2 == null) {
      showSnackBar(context, "Please select both images", isError: true);
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
          ? '✅ Match Success (${similarity.toStringAsFixed(2)}%)'
          : '❌ Not a Match (${similarity.toStringAsFixed(2)}%)';

      showSnackBar(context, msg);
    } catch (e) {
      showSnackBar(context, "Error comparing faces: $e", isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  double _cosineSimilarity(List<double> v1, List<double> v2) {
    double dot = 0.0;
    double normA = 0.0;
    double normB = 0.0;
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
        backgroundColor: Constants.primaryColor,
        title: const Text(
          'Face Compare',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Compare Two Faces',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Constants.accentColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildImageContainer(
                            image: _image1,
                            onTap: () => _pickFace(1),
                            label: 'Face 1',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildImageContainer(
                            image: _image2,
                            onTap: () => _pickFace(2),
                            label: 'Face 2',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _compareFaces,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.accentColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.compare),
                        label: Text(_loading ? 'Comparing...' : 'Compare Faces'),
                      ),
                    ),
                    if (_similarity != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _similarity! >= 70
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _similarity! >= 70 ? Colors.green : Colors.red,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _similarity! >= 70 ? Icons.check_circle : Icons.cancel,
                              color: _similarity! >= 70 ? Colors.green : Colors.red,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _similarity! >= 70
                                  ? 'Match: ${_similarity!.toStringAsFixed(2)}%'
                                  : 'Not a Match: ${_similarity!.toStringAsFixed(2)}%',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _similarity! >= 70 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageContainer({
    required File? image,
    required VoidCallback onTap,
    required String label,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Constants.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Constants.accentColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(image, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        color: Constants.accentColor,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add $label',
                        style: TextStyle(
                          color: Constants.accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _embeddingService.dispose();
    super.dispose();
  }
} 