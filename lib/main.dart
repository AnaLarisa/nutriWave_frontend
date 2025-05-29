import 'package:flutter/material.dart';
import 'pages/authentication/login_page.dart';
import 'pages/authentication/signUp_page.dart';
import 'pages/home_page.dart';
import 'theme/nutriwave_theme.dart'; // Import your theme

void main() {
  runApp(const NutriWaveApp());
}

class NutriWaveApp extends StatelessWidget {
  const NutriWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriWave',
      theme: NutriWaveTheme.lightTheme,
      darkTheme: NutriWaveTheme.darkTheme, // Add dark theme
      themeMode: ThemeMode.dark, // Force dark theme (you can change to ThemeMode.system for auto)
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/': (context) => const HomePage()
      },
    );
  }
}