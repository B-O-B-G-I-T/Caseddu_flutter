import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget viewPicturesWidget({required BuildContext context, required List<String> pictures}) {
  return Wrap(
    spacing: 4.0, // Espacement horizontal entre les images
    runSpacing: 4.0, // Espacement vertical entre les images
    children: pictures.map((picture) {
      return GestureDetector(
        onTap: () {
          // Afficher l'image en grand
          //_showFullScreenImage(context, picture);
          context.push(
            '/fullScreenImage/:filePath',
            extra: picture,
          );
        },
        child: SizedBox(
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

void _showFullScreenImage(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Adapte la taille de la boîte de dialogue en fonction de son contenu
          children: [
            // L'image prend tout l'espace disponible sauf celui des boutons
            Expanded(
              child: Image.asset(
                imageUrl,
                fit: BoxFit.contain, // Ajuste l'image pour remplir le conteneur tout en conservant les proportions
              ),
            ),
            // Ajout de trois boutons en bas
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Action pour le premier bouton
                      Navigator.of(context).pop(); // Fermer la boîte de dialogue
                    },
                    child: Text('Fermer'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Action pour le deuxième bouton
                    },
                    child: Text('Partager'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Action pour le troisième bouton
                    },
                    child: Text('Télécharger'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
