import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:nutriwave_frontend/pages/logo_loading_page.dart';
import 'pages/authentication/login_page.dart';
import 'pages/authentication/signUp_page.dart';
import 'pages/home_page.dart';
import 'theme/nutriwave_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  
  await FlutterDownloader.initialize(
    debug: true, // Set to false in production
    ignoreSsl: true, // Set to false in production
  );
  
  runApp(const NutriWaveApp());
}

class NutriWaveApp extends StatelessWidget {
  const NutriWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriWave',
      theme: NutriWaveTheme.lightTheme,
      darkTheme: NutriWaveTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/logo-loading': (context) => const LogoLoadingPage(),
        '/': (context) => const HomePage()
      },
    );
  }
}