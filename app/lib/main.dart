import 'package:flutter/material.dart';

void main() {
  runApp(HarverstHub());
}

class HarverstHub extends StatelessWidget {
  const HarverstHub({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HarverstHub',
      theme: ThemeData(
        primarySwatch: Colors.teal, // You can adjust the primary color
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(), // Start with the login page
      routes: {
        '/home': (context) => HomePage(),
        '/sample': (context) => SamplePage(),
        '/sample_pesticides': (context) => SamplePesticidesPage(),
        '/sample_weather': (context) => SampleWeatherPage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(decoration: InputDecoration(labelText: 'Username')),
            TextField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home'); // Navigate to home after successful login
              },
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(decoration: InputDecoration(labelText: 'Username')),
            TextField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(decoration: InputDecoration(labelText: 'Email')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home'); // Navigate to home after successful signup
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HarverstHub'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // User profile action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Rectangle tab (App Name and User Logo)
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.teal[100], // Adjust color as needed
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('HarverstHub', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    CircleAvatar(child: Icon(Icons.person)), // User logo
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Three square boxes
            Expanded(
              child: GridView.count(
                crossAxisCount: 1,
                mainAxisSpacing: 20,
                children: <Widget>[
                  _buildRoundedBox(
                    context,
                    'Crop Field',
                    'assets/crop_field.jpg', // Replace with your image asset path
                    '/sample',
                  ),
                  _buildRoundedBox(
                    context,
                    'Pesticides',
                    'assets/pesticides.jpg', // Replace with your image asset path
                    '/sample_pesticides',
                  ),
                  _buildRoundedBox(
                    context,
                    'Weather',
                    'assets/weather.jpg', // Replace with your image asset path
                    '/sample_weather',
                    weatherInfo: '25°C Sunny', // Example weather info
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundedBox(BuildContext context, String title, String imagePath, String route, {String? weatherInfo}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken), // Darken image
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
              ),
              if (weatherInfo != null)
                Text(
                  weatherInfo,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sample pages
class SamplePage extends StatelessWidget {
  const SamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crop Field Page')),
      body: Center(child: Text('Crop Field Content')),
    );
  }
}

class SamplePesticidesPage extends StatelessWidget {
  const SamplePesticidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pesticides Page')),
      body: Center(child: Text('Pesticides Content')),
    );
  }
}

class SampleWeatherPage extends StatelessWidget {
  const SampleWeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather Page')),
      body: Center(child: Text('Weather Content')),
    );
  }
}