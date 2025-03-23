import 'package:flutter/material.dart';
import 'package:harvesthub/models/crop_model.dart';
import 'package:harvesthub/gemini_service.dart';
import 'package:harvesthub/screens/weather_screen.dart'; // For Secrets class

class CropAdvisorScreen extends StatefulWidget {
  const CropAdvisorScreen({super.key});

  @override
  State<CropAdvisorScreen> createState() => _CropAdvisorScreenState();
}

class _CropAdvisorScreenState extends State<CropAdvisorScreen> {
  final TextEditingController _regionController = TextEditingController();
  final List<Crop> _crops = Crop.sampleCrops();
  String _selectedSeason = 'Spring';
  Crop? _selectedCrop;
  String _cropAdvice = '';
  bool _isLoading = false;

  final List<String> _seasons = ['Spring', 'Summer', 'Fall', 'Winter'];

  @override
  void initState() {
    super.initState();
    _regionController.text = 'Midwest Region';
    _selectedCrop = _crops.first;
  }

  @override
  void dispose() {
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _getAdviceFromGemini() async {
    if (_selectedCrop == null) return;
    
    setState(() {
      _isLoading = true;
      _cropAdvice = 'Loading AI recommendations...';
    });

    try {
      final geminiService = GeminiService(Secrets.geminiApiKey);
      final advice = await geminiService.getCropAdvice(
        _selectedCrop!.name, 
        _regionController.text, 
        _selectedSeason
      );
      
      setState(() {
        _cropAdvice = advice;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _cropAdvice = 'Failed to get recommendations. Please try again later.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Advisor'),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Crop and Location',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildCropSelector(),
              const SizedBox(height: 16),
              _buildParametersCard(),
              const SizedBox(height: 24),
              _buildGenerateButton(),
              const SizedBox(height: 16),
              _buildAdviceSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCropSelector() {
    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _crops.length,
        itemBuilder: (context, index) {
          final crop = _crops[index];
          final isSelected = _selectedCrop?.name == crop.name;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCrop = crop;
              });
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green.shade100 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.grass,
                    color: Colors.green.shade700,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    crop.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${crop.growingDays} days',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildParametersCard() {
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
            TextField(
              controller: _regionController,
              decoration: InputDecoration(
                labelText: 'Region/Location',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Growing Season',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _seasons.map((season) {
                final isSelected = _selectedSeason == season;
                return ChoiceChip(
                  label: Text(season),
                  selected: isSelected,
                  selectedColor: Colors.green.shade200,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSeason = season;
                    });
                  },
                );
              }).toList(),
            ),
            if (_selectedCrop != null) ...[
              const SizedBox(height: 16),
              Text(
                'Soil Type: ${_selectedCrop!.soilType}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Water Requirements: ${_selectedCrop!.waterRequirements}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Sunlight: ${_selectedCrop!.sunlightRequirements}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _getAdviceFromGemini,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
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
                'Generate Crop Recommendations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildAdviceSection() {
    if (_cropAdvice.isEmpty) {
      return const SizedBox.shrink();
    }
    
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
                  Icons.lightbulb,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Recommendations for ${_selectedCrop?.name ?? "Crop"}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _cropAdvice,
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
}