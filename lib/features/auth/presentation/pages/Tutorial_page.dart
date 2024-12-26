// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialPage extends StatelessWidget {
  // Liste des pages du tutoriel
  final pages = [
    PageModel(
      title: "Bienvenue!",
      body: "Découvrez toutes les fonctionnalités de notre application.",
      imageAssetPath: "assets/image1.png", // Votre image
      color: Colors.blue,
    ),
    PageModel(
      title: "Fonctionnalité 1",
      body: "Apprenez comment utiliser cette fonctionnalité.",
      imageAssetPath: "assets/image2.png", // Votre image
      color: Colors.green,
    ),
    PageModel(
      title: "Fonctionnalité 2",
      body: "Voici comment cette fonctionnalité peut vous aider.",
      imageAssetPath: "assets/image3.png", // Votre image
      color: Colors.orange,
    ),
  ];

  TutorialPage({super.key});

  finishfunction(BuildContext context) async {
    
      // Marquer que l'utilisateur a vu le tutoriel
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenTutorial', true); // Sauvegarder la préférence

      // Aller à la page d'accueil après le tutoriel
      //context.pop();
      context.go('/firstPage/0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OverBoard(
        pages: pages,
        skipCallback: () {
          finishfunction(context);
        },
        //showSkipBtn: true, // Afficher le bouton "Passer"
        skipText: "Passer",
        finishText: "Terminer",
        finishCallback: () async {
          finishfunction(context);
        },
      ),
    );
  }
}
