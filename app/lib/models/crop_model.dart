class Crop {
  final String name;
  final String description;
  final String imageUrl;
  final List<String> growingSeasons;
  final String soilType;
  final String waterRequirements;
  final String sunlightRequirements;
  final int growingDays;
  final List<String> commonPests;
  final List<String> commonDiseases;
  final String fertilizerRecommendations;

  Crop({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.growingSeasons,
    required this.soilType,
    required this.waterRequirements,
    required this.sunlightRequirements,
    required this.growingDays,
    required this.commonPests,
    required this.commonDiseases,
    required this.fertilizerRecommendations,
  });

  // Sample crops for testing
  static List<Crop> sampleCrops() {
    return [
      Crop(
        name: 'Wheat',
        description: 'A cereal grain which is a worldwide staple food.',
        imageUrl: 'https://example.com/wheat.jpg',
        growingSeasons: ['Winter', 'Spring'],
        soilType: 'Well-drained loamy soil',
        waterRequirements: 'Moderate (450-650mm seasonal)',
        sunlightRequirements: 'Full sun',
        growingDays: 120,
        commonPests: ['Aphids', 'Armyworms', 'Hessian fly'],
        commonDiseases: ['Rust', 'Powdery mildew', 'Septoria leaf blotch'],
        fertilizerRecommendations: 'Nitrogen-rich fertilizer; apply before planting and during tillering stage.',
      ),
      Crop(
        name: 'Rice',
        description: 'A staple food for more than half of the world's population.',
        imageUrl: 'https://example.com/rice.jpg',
        growingSeasons: ['Summer'],
        soilType: 'Clay or loamy soil with good water retention',
        waterRequirements: 'High (fields often flooded)',
        sunlightRequirements: 'Full sun',
        growingDays: 120,
        commonPests: ['Rice water weevil', 'Rice stem borer', 'Brown planthopper'],
        commonDiseases: ['Rice blast', 'Bacterial leaf blight', 'Sheath blight'],
        fertilizerRecommendations: 'NPK fertilizer with emphasis on nitrogen; apply in split doses.',
      ),
      Crop(
        name: 'Corn (Maize)',
        description: 'A cereal grain first domesticated in Mexico.',
        imageUrl: 'https://example.com/corn.jpg',
        growingSeasons: ['Spring', 'Summer'],
        soilType: 'Well-drained, fertile soil',
        waterRequirements: 'Moderate (500-800mm seasonal)',
        sunlightRequirements: 'Full sun',
        growingDays: 90,
        commonPests: ['Corn earworm', 'European corn borer', 'Corn rootworm'],
        commonDiseases: ['Common rust', 'Northern corn leaf blight', 'Gray leaf spot'],
        fertilizerRecommendations: 'Balanced NPK fertilizer; apply at planting and when plants are knee-high.',
      ),
    ];
  }
}