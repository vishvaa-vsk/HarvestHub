import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-pro-preview-0409',
      apiKey: apiKey,
    );
  }

  Future<String> sendMessage(String message) async {
    try {
      final content = [Content.text(message)];
      final response = await _model.generateContent(content);
      final text = response.text;
      if (text == null) {
        return "No response.";
      }
      return text;
    } catch (e) {
      return "Error: $e";
    }
  }
  
  // Get weather interpretation and farming advice based on weather data
  Future<String> getWeatherAdvice(Map<String, dynamic> weatherData) async {
    final prompt = '''
    As a farming expert, analyze this weather data and provide farming advice:
    
    Temperature: ${weatherData['temperature']}°C
    Humidity: ${weatherData['humidity']}%
    Wind Speed: ${weatherData['windSpeed']} km/h
    Rainfall: ${weatherData['rainfall']} mm
    Weather Description: ${weatherData['description']}
    
    Please provide:
    1. How this weather might impact different crops
    2. Recommended actions for farmers today
    3. Potential risks and how to mitigate them
    4. If this is good weather for planting, harvesting, or applying treatments
    ''';
    
    return await sendMessage(prompt);
  }
  
  // Get crop recommendations and techniques
  Future<String> getCropAdvice(String cropName, String region, String season) async {
    final prompt = '''
    As an agricultural expert, provide detailed farming advice for growing $cropName in $region during $season season.
    
    Please include:
    1. Ideal soil conditions and preparation techniques
    2. Optimal planting schedule and methods
    3. Water requirements and irrigation tips
    4. Fertilization schedule and recommendations
    5. Common pests and diseases with organic and conventional control methods
    6. Harvesting indicators and techniques
    7. Post-harvest handling recommendations
    8. Expected yield estimates for well-managed crops
    9. Specific considerations for $region's climate
    ''';
    
    return await sendMessage(prompt);
  }
  
  // Get resource optimization suggestions
  Future<String> getResourceOptimizationAdvice(String resourceType, String currentPractices, String farmSize) async {
    final prompt = '''
    As a sustainable farming consultant, suggest ways to optimize $resourceType usage for a $farmSize farm.
    
    Current practices: $currentPractices
    
    Please provide:
    1. Efficient $resourceType management techniques suitable for this farm size
    2. Technology or equipment recommendations with estimated costs and ROI
    3. Sustainable alternatives or complementary methods
    4. Implementation steps in order of priority
    5. Expected benefits in terms of resource savings, yield impact, and environmental benefits
    6. Common mistakes to avoid during implementation
    7. Maintenance requirements for suggested systems
    ''';
    
    return await sendMessage(prompt);
  }
  
  // Get pest and disease identification and treatment advice based on image or description
  Future<String> getPestAndDiseaseAdvice(String cropType, String symptoms) async {
    final prompt = '''
    As a plant pathologist and pest management expert, analyze these symptoms on $cropType:
    
    $symptoms
    
    Please provide:
    1. Potential pests or diseases that match these symptoms
    2. Confirmation indicators to properly identify the issue
    3. Immediate control measures to prevent spread
    4. Long-term management strategies
    5. Organic treatment options
    6. Chemical treatment options (if necessary)
    7. Preventative measures for future growing seasons
    8. Whether this issue poses risks to other nearby crops
    ''';
    
    return await sendMessage(prompt);
  }
}
