import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Service class for handling pest detection API calls
class PestDetectionService {
  static const String _baseUrl =
      'https://harvesthub-pest-api-47719572182.us-central1.run.app';

  /// Compresses image to bytes for optimal API performance
  static Future<Uint8List> _compressImageToBytes(File imageFile) async {
    try {
      // Skip compression for small files
      final fileSizeBytes = await imageFile.length();
      const maxSizeBytes =
          800 * 1024; // 800KB threshold (reduced for faster processing)

      if (fileSizeBytes <= maxSizeBytes) {
        print(
          '📱 Image size: ${(fileSizeBytes / 1024).toStringAsFixed(1)}KB - Skipping compression',
        );
        return await imageFile.readAsBytes();
      }

      print(
        '📱 Image size: ${(fileSizeBytes / 1024 / 1024).toStringAsFixed(1)}MB - Compressing...',
      );

      // Use adaptive compression based on file size
      int quality = 70;
      int targetWidth = 600;
      int targetHeight = 400;

      // For very large files (>5MB), use more aggressive compression
      if (fileSizeBytes > 5 * 1024 * 1024) {
        quality = 60;
        targetWidth = 500;
        targetHeight = 350;
      }

      final compressionStopwatch = Stopwatch()..start();

      // Compress to bytes (faster than file operations)
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        quality: quality,
        minWidth: targetWidth,
        minHeight: targetHeight,
        format: CompressFormat.jpeg,
      );

      compressionStopwatch.stop();
      print(
        '⚡ Compression completed in ${compressionStopwatch.elapsedMilliseconds}ms',
      );

      final result = compressedBytes ?? await imageFile.readAsBytes();
      print('📦 Final size: ${(result.length / 1024).toStringAsFixed(1)}KB');

      return result;
    } catch (e) {
      print('❌ Compression failed: $e - Using original file');
      // Return original file bytes if compression fails
      return await imageFile.readAsBytes();
    }
  }

  /// Predicts pest issues based on uploaded image
  ///
  /// [imageFile] - The image file to analyze
  /// [languageCode] - Language code for the response (en, ta, te, hi, ml)
  ///
  /// Returns a Map containing prediction results and recommendations
  static Future<Map<String, dynamic>> predictPest({
    required File imageFile,
    required String languageCode,
  }) async {
    try {
      final totalStopwatch = Stopwatch()..start();

      // Compress to bytes (faster than file compression)
      final imageBytes = await _compressImageToBytes(imageFile);

      print('🌐 Preparing API request...');
      final networkStopwatch = Stopwatch()..start();

      // Create multipart request
      final uri = Uri.parse('$_baseUrl/predict/$languageCode');
      final request = http.MultipartRequest('POST', uri);

      // Add image bytes directly
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'image.jpg',
      );
      request.files.add(multipartFile);

      // Set headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      });

      print('📡 Sending request to API...');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      networkStopwatch.stop();
      totalStopwatch.stop();

      print('🔗 Network time: ${networkStopwatch.elapsedMilliseconds}ms');
      print(
        '⏱️ Total processing time: ${totalStopwatch.elapsedMilliseconds}ms',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception(
          'Failed to predict pest: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error calling pest detection API: $e');
    }
  }

  /// Formats the prediction response for display
  static Map<String, dynamic> formatPredictionResponse(
    Map<String, dynamic> apiResponse,
  ) {
    try {
      final prediction = apiResponse['prediction'] ?? {};
      final recommendation = apiResponse['recommendation'] ?? {};
      final language = apiResponse['language'] ?? {};

      return {
        'status': apiResponse['status'] ?? 'unknown',
        'pestLabel': prediction['label'] ?? 'Unknown',
        'confidence': prediction['confidence'] ?? 0.0,
        'diagnosis': recommendation['diagnosis'] ?? 'No diagnosis available',
        'causalAgent': recommendation['causal_agent'] ?? 'Unknown cause',
        'treatments': recommendation['treatments'] ?? [],
        'language': language['name'] ?? 'Unknown',
        'timestamp':
            apiResponse['timestamp'] ?? DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Error formatting prediction response: $e');
    }
  }
}
