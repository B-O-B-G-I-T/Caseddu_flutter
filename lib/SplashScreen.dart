// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simule une attente, puis passe à l'écran principal
    Future.delayed(const Duration(seconds: 3), () {
      context.go('/firstPage/0');
    });
  }

  @override
  Widget build(BuildContext context) {
    Locale myLocale = Localizations.localeOf(context); // Obtenir la locale actuelle

    // Déterminer l'image et le titre en fonction de la langue
    String splashImage = 'assets/icons/qrCodeIcon.png';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(splashImage),
            const SizedBox(height: 20),
            const Text('My App', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

