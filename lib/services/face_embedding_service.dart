import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceEmbeddingService {
  Interpreter? _interpreter;

  /// ✅ Public getter to access interpreter safely
  bool get isModelLoaded => _interpreter != null;

  Future<void> loadModel() async {
    final modelData = await rootBundle.load('assets/models/mobilefacenet.tflite');
    final modelPath = await _writeToFile(modelData, 'mobilefacenet.tflite');
    _interpreter = await Interpreter.fromFile(File(modelPath));
    print('✅ TFLite model loaded successfully.');
  }

  Future<List<double>> extractEmbedding(File imageFile) async {
    if (_interpreter == null) {
      throw Exception("Interpreter not loaded. Call loadModel() first.");
    }

    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) throw Exception("Failed to decode image");

    final resized = img.copyResize(image, width: 112, height: 112);

    final input = List.generate(112, (y) {
      return List.generate(112, (x) {
        final pixel = resized.getPixel(x, y);
        return [
          pixel.r / 128.0 - 1.0,
          pixel.g / 128.0 - 1.0,
          pixel.b / 128.0 - 1.0,
        ];
      });
    });

    final output = List.filled(192, 0.0).reshape([1, 192]);
    _interpreter!.run([input], output);
    return List<double>.from(output[0]);
  }

  /// ✅ Cosine similarity between two embeddings
  double compareEmbeddings(List<double> emb1, List<double> emb2) {
    if (emb1.length != emb2.length) throw Exception("Embeddings must be the same length");

    double dot = 0.0, normA = 0.0, normB = 0.0;

    for (int i = 0; i < emb1.length; i++) {
      dot += emb1[i] * emb2[i];
      normA += emb1[i] * emb1[i];
      normB += emb2[i] * emb2[i];
    }

    return dot / (sqrt(normA) * sqrt(normB));
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    print('🗑️ TFLite interpreter disposed.');
  }

  Future<String> _writeToFile(ByteData data, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, filename));
    await file.writeAsBytes(data.buffer.asUint8List());
    return file.path;
  }
}
