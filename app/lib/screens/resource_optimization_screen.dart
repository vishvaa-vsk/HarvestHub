import 'package:flutter/material.dart';
import 'package:harvesthub/gemini_service.dart';
import 'package:harvesthub/models/resource_optimization_model.dart';
import 'package:harvesthub/screens/weather_screen.dart'; // For Secrets class

class ResourceOptimizationScreen extends StatefulWidget {
  const ResourceOptimizationScreen({super.key});

  @override
  State<ResourceOptimizationScreen> createState() => _ResourceOptimizationScreenState();
}

class _ResourceOptimizationScreenState extends State<ResourceOptimizationScreen> {
  final List<ResourceOptimization> _optimizations = ResourceOptimization.sampleOptimizations();
  final TextEditingController _currentPracticesController = TextEditingController();
  final TextEditingController _farmSizeController = TextEditingController();
  
  String _selectedResourceType = 'Water';
  String _aiRecommendation = '';
  bool _isLoading = false;
  
  final List<String> _resourceTypes = ['Water', 'Fertilizer', 'Pesticide', 'Energy', 'Labor', 'Soil'];
  
  @override
  void initState() {
    super.initState();
    _currentPracticesController.text = 'Currently using traditional irrigation methods with overhead sprinklers.';
    _farmSizeController.text = '25 acres';
  }
  
  @override
  void dispose() {
    _currentPracticesController.dispose();
    _farmSizeController.dispose();
    super.dispose();
  }

  Future<void> _getOptimizationRecommendations() async {
    setState(() {
      _isLoading = true;
      _aiRecommendation = 'Generating AI recommendations...';
    });

    try {
      final geminiService = GeminiService(Secrets.geminiApiKey);
      final advice = await geminiService.getResourceOptimizationAdvice(
        _selectedResourceType,
        _currentPracticesController.text,
        _farmSizeController.text,
      );
      
      setState(() {
        _aiRecommendation = advice;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _aiRecommendation = 'Failed to get recommendations. Please try again later.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Optimization'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Common Optimization Techniques',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildOptimizationList(),
              const SizedBox(height: 24),
              const Text(
                'Get Personalized AI Recommendations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildPersonalizationForm(),
              const SizedBox(height: 20),
              _buildGenerateButton(),
              const SizedBox(height: 16),
              if (_aiRecommendation.isNotEmpty) _buildRecommendationCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizationList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _optimizations.length,
      itemBuilder: (context, index) {
        final optimization = _optimizations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: Icon(
              _getIconForName(optimization.iconName),
              color: _getColorForCategory(optimization.category),
              size: 32,
            ),
            title: Text(
              optimization.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '${optimization.category} • Impact: ${optimization.impact} • Difficulty: ${optimization.implementationDifficulty}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      optimization.description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Implementation Steps:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...optimization.steps.map((step) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 14)),
                          Expanded(
                            child: Text(
                              step,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 12),
                    const Text(
                      'Benefits:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...optimization.benefits.map((benefit) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✓ ', style: TextStyle(fontSize: 14, color: Colors.green)),
                          Expanded(
                            child: Text(
                              benefit,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonalizationForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resource Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _resourceTypes.map((type) {
                final isSelected = _selectedResourceType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  selectedColor: Colors.teal.shade200,
                  onSelected: (selected) {
                    setState(() {
                      _selectedResourceType = type;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _farmSizeController,
              decoration: InputDecoration(
                labelText: 'Farm Size',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.crop_square),
                hintText: 'e.g. 25 acres, 10 hectares',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _currentPracticesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Current Practices',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Describe your current farming methods related to this resource',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _getOptimizationRecommendations,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade700,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Get Personalized Recommendations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Recommendations for $_selectedResourceType Optimization',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _aiRecommendation,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForName(String iconName) {
    switch (iconName) {
      case 'water_drop':
        return Icons.water_drop;
      case 'scatter_plot':
        return Icons.scatter_plot;
      case 'replay':
        return Icons.replay;
      default:
        return Icons.eco;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Water':
        return Colors.blue;
      case 'Fertilizer':
        return Colors.brown;
      case 'Soil':
        return Colors.amber.shade800;
      case 'Energy':
        return Colors.orange;
      case 'Pesticide':
        return Colors.red;
      default:
        return Colors.teal;
    }
  }
}