class ResourceOptimization {
  final String title;
  final String description;
  final String category; // Water, Fertilizer, Pesticide, Energy, etc.
  final String impact; // High, Medium, Low
  final String implementationDifficulty; // Easy, Medium, Hard
  final List<String> steps;
  final List<String> benefits;
  final String iconName;

  ResourceOptimization({
    required this.title,
    required this.description,
    required this.category,
    required this.impact,
    required this.implementationDifficulty,
    required this.steps,
    required this.benefits,
    required this.iconName,
  });

  // Sample resource optimization techniques
  static List<ResourceOptimization> sampleOptimizations() {
    return [
      ResourceOptimization(
        title: 'Drip Irrigation',
        description: 'A water-efficient irrigation method that delivers water directly to the plant roots.',
        category: 'Water',
        impact: 'High',
        implementationDifficulty: 'Medium',
        steps: [
          'Plan your field layout',
          'Purchase drip irrigation components',
          'Install main water line',
          'Place drip lines along crop rows',
          'Install filters and pressure regulators',
          'Test the system'
        ],
        benefits: [
          'Reduces water usage by up to 60%',
          'Minimizes soil erosion',
          'Reduces weed growth',
          'Improves crop yield and quality'
        ],
        iconName: 'water_drop',
      ),
      ResourceOptimization(
        title: 'Precision Fertilizer Application',
        description: 'Using soil testing and GPS technology to apply the right amount of fertilizer in the right places.',
        category: 'Fertilizer',
        impact: 'High',
        implementationDifficulty: 'Hard',
        steps: [
          'Conduct comprehensive soil testing',
          'Create field fertility maps',
          'Calibrate application equipment',
          'Apply fertilizer according to soil needs',
          'Monitor results'
        ],
        benefits: [
          'Reduces fertilizer waste',
          'Decreases environmental impact',
          'Improves nutrient utilization',
          'Reduces costs'
        ],
        iconName: 'scatter_plot',
      ),
      ResourceOptimization(
        title: 'Crop Rotation',
        description: 'Planting different crops in the same area across growing seasons to improve soil health.',
        category: 'Soil',
        impact: 'Medium',
        implementationDifficulty: 'Easy',
        steps: [
          'Plan your crop sequence',
          'Consider crop families and nutrient needs',
          'Include cover crops when possible',
          'Keep records of rotations',
          'Adjust rotation based on results'
        ],
        benefits: [
          'Reduces soil erosion',
          'Improves soil structure and fertility',
          'Disrupts pest and disease cycles',
          'Reduces dependency on synthetic fertilizers'
        ],
        iconName: 'replay',
      ),
    ];
  }
}