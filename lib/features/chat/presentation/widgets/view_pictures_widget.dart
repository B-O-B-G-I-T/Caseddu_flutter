import 'package:flutter/material.dart';

Widget viewPicturesWidget({required BuildContext context, required List<String> pictures}) {
  return Wrap(
    spacing: 4.0, // Espacement horizontal entre les images
    runSpacing: 4.0, // Espacement vertical entre les images
    children: pictures.map((picture) {
      return GestureDetector(
        onTap: () {
          // Afficher l'image en grand
          _showFullScreenImage(context, picture);
        },
        child: Container(
          width: 150, // Largeur maximale pour chaque image
          height: 200, // Hauteur maximale pour chaque image
          child: FittedBox(
            fit: BoxFit.contain, // Ajuste l'image pour remplir le conteneur tout en conservant les proportions
            child: Image.asset(picture),
          ),
        ),
      );
    }).toList(),
  );
}

// Fonction pour afficher une image en plein écran
void _showFullScreenImage(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Image.asset(
          imageUrl,
          fit: BoxFit.contain, // Ajuste l'image pour remplir le conteneur tout en conservant les proportions
        ),
      );
    },
  );
}
