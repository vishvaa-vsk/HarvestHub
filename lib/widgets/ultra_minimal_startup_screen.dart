import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harvesthub/core/constants/app_constants.dart';

/// Ultra-lightweight startup screen optimized for maximum performance
/// This widget has minimal complexity to allow immediate rendering
class UltraMinimalStartupScreen extends StatelessWidget {
  const UltraMinimalStartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(AppConstants.defaultSystemUIStyle);

    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simplified logo placeholder
            Icon(Icons.agriculture, size: 48, color: Color(0xFF4CAF50)),
            SizedBox(height: 16),
            // Minimal text
            Text(
              'HarvestHub',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            SizedBox(height: 24),
            // Minimal progress indicator
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
