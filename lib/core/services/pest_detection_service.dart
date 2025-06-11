import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

/// Service class for handling pest detection API calls
class PestDetectionService {
  static const String _baseUrl =
      'https://harvesthub-pest-api-47719572182.us-central1.run.app';

  /// Compresses an image file for optimal API performance
  static Future<File> _compressImage(File imageFile) async {
    try {
      final String fileName = path.basename(imageFile.path);
      final String targetPath = path.join(
        path.dirname(imageFile.path),
        'compressed_$fileName',
      );

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 85,
        minWidth: 800,
        minHeight: 600,
        format: CompressFormat.jpeg,
      );

      if (compressedFile != null) {
        return File(compressedFile.path);
      } else {
        return imageFile;
      }
    } catch (e) {
      // Return original file if compression fails
      return imageFile;
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
      // Compress the image for optimal API performance
      final compressedImage = await _compressImage(imageFile);

      // Create multipart request
      final uri = Uri.parse('$_baseUrl/predict/$languageCode');
      final request = http.MultipartRequest('POST', uri);

      // Add the compressed image file
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        compressedImage.path,
      );
      request.files.add(multipartFile);

      // Set headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      });

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Clean up compressed file if it's different from original
      if (compressedImage.path != imageFile.path) {
        try {
          await compressedImage.delete();
        } catch (e) {
          // Ignore cleanup errors
        }
      }

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
