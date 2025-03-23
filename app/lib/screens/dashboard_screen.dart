import 'package:flutter/material.dart';
import 'package:harvesthub/screens/weather_screen.dart';
import 'package:harvesthub/screens/crop_advisor_screen.dart';
import 'package:harvesthub/screens/resource_optimization_screen.dart';
import 'package:harvesthub/screens/pest_disease_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HarvestHub'),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade500,
              Colors.green.shade100,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to HarvestHub',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your AI-powered farming assistant',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green.shade900,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildFeatureCard(
                      context,
                      'Weather Insights',
                      Icons.cloud,
                      'Get real-time weather updates and farming recommendations',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WeatherScreen(),
                        ),
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      'Crop Advisor',
                      Icons.grass,
                      'Smart techniques for better crop yields',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CropAdvisorScreen(),
                        ),
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      'Resource Optimization',
                      Icons.water_drop,
                      'Optimize water, fertilizer, and energy usage',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResourceOptimizationScreen(),
                        ),
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      'Pest & Disease',
                      Icons.bug_report,
                      'Identify and treat plant pests and diseases',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PestDiseaseScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}