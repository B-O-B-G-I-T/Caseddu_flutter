import 'package:flutter/material.dart';

Widget viewPicturesWidget({required List<String> pictures}) {
  return SizedBox(
    height: 120, // Hauteur de la liste d'images
    child: ListView.builder(
      scrollDirection: Axis.horizontal, // Pour afficher les images horizontalement
      itemCount: pictures.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            // Afficher l'image en grand
            _showFullScreenImage(context, pictures[index]);
          },
          child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 8, 8), // Espacement entre chaque image
              height: 150,
              width: 120, // Utilise chaque chemin d'image dans la liste
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Image.asset(
                pictures[index],
                fit: BoxFit.cover,
              )),
        );
      },
    ),
  );
}
// TODO: faire une preview plus propre ici fonctionnelle 
void _showFullScreenImage(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Image.asset(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      );
    },
  );
}
