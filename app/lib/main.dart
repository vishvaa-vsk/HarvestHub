import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv
import 'package:google_generative_ai/google_generative_ai.dart';
import 'firebase_options.dart'; // Import the generated firebase_options.dart file
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:harvesthub/app_localizations.dart';
import 'dart:async';
import 'package:harvesthub/gemini_service.dart';

class Secrets {
  static late String geminiApiKey;
}

Future<void> loadSecrets() async {
  await dotenv.load(fileName: ".env"); // Call dotenv.load()

  Secrets.geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? 'gemini_key';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Call dotenv.load()
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform); // Access DefaultFirebaseOptions
  await loadSecrets();
  runApp(HarverstHub());
}

class HarverstHub extends StatelessWidget {
  const HarverstHub({super.key});

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
        Locale('en'), // English
        Locale('es'), // Spanish
        Locale('fr'), // French
      ],
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final geminiService = GeminiService(Secrets.geminiApiKey);
  String geminiResponse = "";

  void _sendPromptToGemini() async {
    final response = await geminiService.sendMessage("Hello Gemini!");

    setState(() {
      geminiResponse = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HarvestHub"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.helloWorld,
              style: TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed: _sendPromptToGemini,
              child: const Text("Send Prompt to Gemini"),
            ),
            SizedBox(height: 20),
            Text(
              geminiResponse,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
