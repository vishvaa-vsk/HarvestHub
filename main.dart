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
      body: Center(
        child: Image.asset('assets/images/crop.jpg'), // Replace with your image path
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

  void _sendOtp() {
    setState(() {
      _isOtpSent = true;
    });
    print('Sending OTP to ${_phoneNumberController.text}');
  }

  void _verifyOtp() {
    if (_otpController.text == '123456') {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HarvestHub')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'User Name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Mobile Number'),
              ),
              const SizedBox(height: 16),
              if (!_isOtpSent)
                ElevatedButton(onPressed: _sendOtp, child: const Text('Send OTP')),
              if (_isOtpSent)
                Column(
                  children: [
                    TextFormField(
                      controller: _otpController,
                      decoration: InputDecoration(labelText: 'OTP'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _verifyOtp, child: const Text('Continue')),
                  ],
                ),
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
