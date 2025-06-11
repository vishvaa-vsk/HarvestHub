import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../core/constants/app_constants.dart';
import '../core/services/pest_detection_service.dart';

class PestDetectScreen extends StatefulWidget {
  const PestDetectScreen({super.key});

  @override
  State<PestDetectScreen> createState() => _PestDetectScreenState();
}

class _PestDetectScreenState extends State<PestDetectScreen> {
  File? _image;
  bool _scanning = false;
  Map<String, dynamic>? _predictionResult;
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _predictionResult = null;
        _errorMessage = null;
      });
    }
  }

  void _scanImage() async {
    if (_image == null) return;

    setState(() {
      _scanning = true;
      _predictionResult = null;
      _errorMessage = null;
    });

    try {
      final stopwatch = Stopwatch()..start();

      // Get current language code from localization
      final languageCode = AppLocalizations.of(context)!.localeName;

      print('🔍 Starting pest detection...');

      // Call the pest detection API
      final apiResponse = await PestDetectionService.predictPest(
        imageFile: _image!,
        languageCode: languageCode,
      );

      print('✅ API response received in ${stopwatch.elapsedMilliseconds}ms');

      // Format the response for display
      final formattedResult = PestDetectionService.formatPredictionResponse(
        apiResponse,
      );

      stopwatch.stop();
      print('🎯 Total detection time: ${stopwatch.elapsedMilliseconds}ms');

      setState(() {
        _scanning = false;
        _predictionResult = formattedResult;
      });
    } catch (e) {
      setState(() {
        _scanning = false;
        _errorMessage = 'Failed to analyze image: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style for consistent navigation bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.pestDetection,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading:
            Navigator.of(context).canPop()
                ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.of(context).pop(),
                )
                : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black54),
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Section Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: AppConstants.primaryGreen.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      size: 32,
                      color: AppConstants.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.uploadPlantImage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.uploadPlantImageDesc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildImageSourceButton(
                          icon: Icons.camera_alt,
                          label: AppLocalizations.of(context)!.camera,
                          onPressed: () => _pickImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildImageSourceButton(
                          icon: Icons.photo_library,
                          label: AppLocalizations.of(context)!.gallery,
                          onPressed: () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Scan Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _image != null && !_scanning
                          ? AppConstants.primaryGreen
                          : Colors.grey[300],
                  foregroundColor:
                      _image != null && !_scanning
                          ? Colors.white
                          : Colors.grey[500],
                  elevation: _image != null && !_scanning ? 2 : 0,
                  shadowColor: AppConstants.primaryGreen.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _image != null && !_scanning ? _scanImage : null,
                child:
                    _scanning
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.grey[500]!,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(context)!.analyzing,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.analyzeImage,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
              ),
            ),

            const SizedBox(height: 32),

            // Results Section
            Text(
              AppLocalizations.of(context)!.detectionResults,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Image Preview Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child:
                        _image != null
                            ? Image.file(
                              _image!,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              height: 220,
                              width: double.infinity,
                              color: Colors.grey[50],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.noImageSelected,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.uploadImageToGetStarted,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                  // Results Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child:
                        _predictionResult != null
                            ? _buildPredictionResults()
                            : _errorMessage != null
                            ? _buildErrorMessage()
                            : _buildReadyToAnalyze(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.primaryGreen,
        elevation: 0,
        side: BorderSide(
          color: AppConstants.primaryGreen.withValues(alpha: 0.3),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline,
                  size: 20,
                  color: AppConstants.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.howToUse,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpTip(
                AppLocalizations.of(context)!.takeClearPhotos,
                Icons.camera_alt,
              ),
              _buildHelpTip(
                AppLocalizations.of(context)!.focusOnAffectedAreas,
                Icons.center_focus_strong,
              ),
              _buildHelpTip(
                AppLocalizations.of(context)!.avoidBlurryImages,
                Icons.image_not_supported,
              ),
              _buildHelpTip(
                AppLocalizations.of(context)!.includeMultipleLeaves,
                Icons.eco,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.primaryGreen,
              ),
              child: Text(
                AppLocalizations.of(context)!.gotIt,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpTip(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppConstants.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionResults() {
    if (_predictionResult == null) return const SizedBox();

    final pestLabel = _predictionResult!['pestLabel'] ?? 'Unknown';
    final confidence = (_predictionResult!['confidence'] ?? 0.0) * 100;
    final diagnosis =
        _predictionResult!['diagnosis'] ?? 'No diagnosis available';
    final causalAgent = _predictionResult!['causalAgent'] ?? 'Unknown cause';
    final treatments = _predictionResult!['treatments'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pest Detection Result Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                confidence > 70
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  confidence > 70
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.orange.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                confidence > 70 ? Icons.check_circle : Icons.warning,
                color: confidence > 70 ? Colors.green : Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pestLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${AppLocalizations.of(context)!.confidence}: ${confidence.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20), // Diagnosis Section
        _buildResultSection(
          title: AppLocalizations.of(context)!.diagnosis,
          content: diagnosis,
          icon: Icons.medical_information,
        ),

        const SizedBox(height: 16),

        // Causal Agent Section
        _buildResultSection(
          title: AppLocalizations.of(context)!.causalAgent,
          content: causalAgent,
          icon: Icons.bug_report,
        ),

        const SizedBox(height: 16),

        // Treatments Section
        if (treatments.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.healing, size: 20, color: AppConstants.primaryGreen),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.recommendations,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...treatments.asMap().entries.map((entry) {
            String treatment = entry.value.toString();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    height: 6,
                    width: 6,
                    decoration: const BoxDecoration(
                      color: AppConstants.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFormattedText(
                      treatment,
                      baseStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        const SizedBox(height: 20), // Action Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _image = null;
                _predictionResult = null;
                _errorMessage = null;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.primaryGreen,
              side: BorderSide(color: AppConstants.primaryGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.refresh, size: 20),
            label: Text(
              AppLocalizations.of(context)!.scanAgain,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppConstants.primaryGreen),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: _buildFormattedText(
            content,
            baseStyle: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.analysisError,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _errorMessage ?? 'An unknown error occurred',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
                if (_image != null) {
                  _scanImage();
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(AppLocalizations.of(context)!.tryAgain),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyToAnalyze() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            _image != null ? Icons.analytics_outlined : Icons.upload_file,
            size: 48,
            color:
                _image != null ? AppConstants.primaryGreen : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _image != null
                ? AppLocalizations.of(context)!.readyToAnalyze
                : AppLocalizations.of(context)!.uploadImageFirst,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _image != null ? Colors.black87 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _image != null
                ? AppLocalizations.of(context)!.uploadImageAndAnalyze
                : AppLocalizations.of(context)!.uploadImageToGetStarted,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Formats text with basic markdown support (bold, italic)
  Widget _buildFormattedText(String text, {TextStyle? baseStyle}) {
    // Split text by markdown patterns
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');

    int lastIndex = 0;

    // Process bold text first
    for (final Match match in boldPattern.allMatches(text)) {
      // Add text before the match
      if (match.start > lastIndex) {
        final beforeText = text.substring(lastIndex, match.start);
        _processBoldAndItalic(beforeText, spans, baseStyle);
      }

      // Add bold text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: (baseStyle ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      final remainingText = text.substring(lastIndex);
      _processBoldAndItalic(remainingText, spans, baseStyle);
    }

    return RichText(
      text: TextSpan(
        children:
            spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans,
        style: baseStyle ?? const TextStyle(color: Colors.black87),
      ),
    );
  }

  void _processBoldAndItalic(
    String text,
    List<TextSpan> spans,
    TextStyle? baseStyle,
  ) {
    final RegExp italicPattern = RegExp(r'(?<!\*)\*([^*]+)\*(?!\*)');
    int lastIndex = 0;

    for (final Match match in italicPattern.allMatches(text)) {
      // Add text before the match
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      // Add italic text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: (baseStyle ?? const TextStyle()).copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: baseStyle));
    }
  }
}
