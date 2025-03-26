import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:harvesthub/app_localizations.dart';
import 'package:harvesthub/gemini_service.dart';
import 'dart:async';

class Secrets {
  static late String geminiApiKey;
}

Future<void> loadSecrets() async {
  await dotenv.load(fileName: ".env");
  Secrets.geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? 'gemini_key';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await loadSecrets();
  runApp(HarvestHub());
}

class HarvestHub extends StatelessWidget {
  const HarvestHub({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HarvestHub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
      ],
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/crop.jpg',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.agriculture,
                  size: 80,
                  color: Colors.green,
                ),
                SizedBox(height: 16),
                Text(
                  'HarvestHub',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneNumberController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!RegExp(r'^\+?[\d\s-]+$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
  }

  String? _validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter OTP';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }
    return null;
  }

  void _sendOtp() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement Firebase phone authentication
      setState(() {
        _isOtpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent to ${_phoneNumberController.text}')),
      );
    }
  }

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement Firebase OTP verification
      if (_otpController.text == '123456') { // This should be replaced with actual Firebase verification
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(username: _usernameController.text)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HarvestHub'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 32),
              Text(
                'Welcome to HarvestHub',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'User Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: _validateUsername,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: _validatePhoneNumber,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              if (!_isOtpSent)
                ElevatedButton(
                  onPressed: _sendOtp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Send OTP'),
                ),
              if (_isOtpSent) ...[
                TextFormField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateOtp,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Verify & Continue'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final geminiService = GeminiService(Secrets.geminiApiKey);
  String geminiResponse = "";
  String weather = "Sunny"; // Replace with actual weather data
  double temperature = 30.0; // Replace with actual temperature
  double humidity = 60.0; // Replace with actual humidity
  double windSpeed = 10.0; // Replace with actual wind speed
  double rainfall = 0.0; // Replace with actual rainfall

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HarvestHub')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text('Hello, ${widget.username}!'),
            Text('Today is $weather.'),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFB8D53D),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Temp: $temperature°C'),
                  Text('Humidity: $humidity%'),
                  Text('Wind: $windSpeed m/s'),
                  Text('Rain: $rainfall mm'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const WeatherForecastPage()));
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF8DC71E),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Column(
                  children: [
                    Text('Weather Forecast'),
                    Text('Get the latest weather for your crops.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CropAdvisorPage()));
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF69B41E),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Column(
                  children: [
                    Text('Crop Advisor'),
                    Text('Get expert advice on crop management.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherForecastPage extends StatelessWidget {
  const WeatherForecastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Forecast')),
      body: const Center(child: Text('Weather Forecast Page')),
    );
  }
}

class CropAdvisorPage extends StatelessWidget {
  const CropAdvisorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crop Advisor')),
      body: const Center(child: Text('Crop Advisor Page')),
    );
  }
}
