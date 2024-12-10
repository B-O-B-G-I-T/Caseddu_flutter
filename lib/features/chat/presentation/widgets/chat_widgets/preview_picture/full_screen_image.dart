import 'package:caseddu/core/utils/p2p/fonctions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black, // Fond noir

        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // L'image prend tout l'espace disponible sauf celui des boutons
                  Positioned.fill(
                    child: Image.asset(
                      imageUrl,
                      fit: BoxFit.contain, // Ajuste l'image pour remplir le conteneur tout en conservant les proportions
                    ),
                  ),
                  // Ajout d'un bouton "Retour" en haut à gauche
                  Positioned(
                    top: 16.0, // Distance du haut de l'écran
                    left: 16.0, // Distance du bord gauche de l'écran
                    child: CircularIconButton(icon: Icons.arrow_back, onPressed: () => GoRouter.of(context).pop()),
                  ),
                ],
              ),
            ),
            // Les boutons en bas
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircularIconButton(icon: Icons.ios_share, onPressed: () {}),
                    CircularIconButton(
                        icon: Icons.download,
                        onPressed: () async {
                          // Télécharger l'image
                          await Utils.saveImageToGallery(imageUrl, context);
                        }),
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

class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const CircularIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0), // Ajoute un espacement autour du bouton
      decoration: const BoxDecoration(
        shape: BoxShape.circle, // Forme circulaire
        color: Colors.black26, // Fond noir
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white), // Icône personnalisée
        onPressed: onPressed, // Fonction passée en paramètre
      ),
    );
  }
}
